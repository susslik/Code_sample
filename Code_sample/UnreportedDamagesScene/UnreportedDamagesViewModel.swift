//
//  UnreportedDamagesViewModel.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Photos
import MobileCoreServices

import RxSwift
import RxCocoa

enum UnreportedDamagesViewModelError: UserPresentableError {
    case noComment
    case imageIsUploading
    case imageUploadFalied
    
    var userPresentable: Bool { return true }
    var errorDescription: String? {
        switch self {
        case .noComment:
            return L10n.noCommentErrorDescription
        case .imageIsUploading:
            return L10n.imageIsUploadingErrorDescription
        case .imageUploadFalied:
            return L10n.imageUploadingFailedErrorDescription
        }
    }
}

struct UnreportedDamageCellViewModel {
    let damageLocation: DamageLocation
    let image: UploadableImage?
    var title: String { return damageLocation.title }
}

enum DamageLocation: CaseIterable {
    case front
    case back
    case left
    case right
    
    var title: String {
        switch self {
            case.front:
                return L10n.UnreportedDamages.frontTitle
            case .back:
                return L10n.UnreportedDamages.backTitle
            case .left:
                return L10n.UnreportedDamages.leftTitle
            case .right:
                return L10n.UnreportedDamages.rightTitle
        }
    }
}

class UnreportedDamagesViewModel: NSObject {
    let canContinue: BehaviorRelay<Bool> = .init(value: false)
    let loadingState = BehaviorRelay<LoadingState>(value: .none)

    
    let comment = BehaviorRelay<String?>(value: nil)
    let items = BehaviorRelay<[UnreportedDamageCellViewModel]>(value: [])

    private let apiService: ApiService
    
    // Disable 'next' buton while uploading is in process
    private var photoUploadingDispose: Disposable?
    private let photosIsUploading: BehaviorRelay<Bool> = .init(value: false)

    private let photos: BehaviorRelay<[DamageLocation:UploadableImage]> = .init(value: [:])

    private var editingLocation: DamageLocation?
    
    init(apiService: ApiService) {
        self.apiService = apiService
    }

     func setupBindings(with bag: DisposeBag) {
        // Check for uploadings is in process
         photos
            .map { [weak self] photos in
                guard let self = self else { return false }
                self.photoUploadingDispose = nil
                
                let photos = photos.values
                guard photos.isEmpty == false else { return false }
                let observables = photos.compactMap { $0.isUploaded ? nil : $0.isUploading }
                if observables.isEmpty { return false }

                self.photoUploadingDispose = Observable.combineLatest(observables)
                    .map { !$0.contains { $0 == false } }
                    .bind(to: self.photosIsUploading)
                return true
            }
            .bind(to: photosIsUploading)
            .disposed(by: bag)
        
        photos
            .map{ photos in
                DamageLocation.allCases.map{ UnreportedDamageCellViewModel(damageLocation: $0, image: photos[$0]) }
            }
            .bind(to: items)
            .disposed(by: bag)
        
        // If no active uploadings -  'next' button is active
        photosIsUploading
            .map { !$0 }
            .bind(to: canContinue)
            .disposed(by: bag)
     }

    func editImage(at index: IndexPath) {
        guard let item = items.value[safe: index.row] else { return }
        
        var actions = [AlertAction]()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = AlertAction(title: L10n.AlertAction.takePhoto) { [weak self] in
                self?.takePhoto(for: item)
            }
            actions.append(cameraAction)
        }
        
        let libraryAction = AlertAction(title: L10n.AlertAction.selectFromGallery) { [weak self] in
            self?.selectPhotoFromGallery(for: item)
        }
        actions.append(libraryAction)
        
        if item.image != nil {
            let deleteAction = AlertAction(title: L10n.AlertAction.deleteImage, style: .destructive) { [weak self] in
                self?.deleteImage(for: item)
            }
            actions.append(deleteAction)
        }
        
        actions.append(.cancel())
        UIAlertController.show(actions: actions, title: nil, message: nil, style: .actionSheet)
    }

     func deleteImage(for item: UnreportedDamageCellViewModel) {
         var photos = self.photos.value
         photos[item.damageLocation] = nil
         self.photos.accept(photos)
     }

    func onNextPressed() -> Single<Void> {
        return validate(comment: comment.value, photos: photos.value,
                        uploadingsIsInProcess: photosIsUploading.value)
            .do(onError: { [weak self] error in
                self?.loadingState.accept(.loaded(.failed(error: error)))
            })
            .flatMap{ [weak self] damages in
                return self?.upload(damages: damages) ?? .just(())
            }
            .do(onError: { [weak self] error in
                self?.loadingState.accept(.loaded(.failed(error: error)))
            })
    }
    
    func retryUploading(for item: UnreportedDamageCellViewModel) {
         guard
            let image = item.image,
             !image.isUploaded
         else {
             return
         }

        upload(image: image, for: item.damageLocation)
     }
}

// MARK: - Take image

private extension UnreportedDamagesViewModel {
    func takePhoto(for item: UnreportedDamageCellViewModel) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showPicker(with: .camera, for: item)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) {[weak self] granted in
                if !granted { return }
                self?.showPicker(with: .camera, for: item)
            }
        case .denied:
            showSettingsAlert(message: L10n.AlertMessage.cameraDenied)
        case .restricted: break
        @unknown default:
            break
        }
    }
    
    func selectPhotoFromGallery(for item: UnreportedDamageCellViewModel) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            showPicker(with: .photoLibrary, for: item)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization {[weak self] status in
                if status != .authorized { return }
                self?.showPicker(with: .photoLibrary, for: item)
            }
        case .denied:
            showSettingsAlert(message: L10n.AlertMessage.libraryDenied)
        case .restricted: break
        case .limited:
            let settingsAction = AlertAction(title: L10n.AlertAction.openSettings, style: .default) {
                UIApplication.open(url: UIApplication.openSettingsURLString)
            }

            let galleryAction = AlertAction(title: L10n.AlertAction.openGallery, style: .default) { [weak self] in
                self?.showPicker(with: .photoLibrary, for: item)
            }

            UIAlertController.show(actions: [settingsAction, galleryAction],
                                   title: L10n.AlertTitle.libraryLimited,
                                   message: L10n.AlertMessage.libraryLimited, style: .alert)
            @unknown default:
            break
        }
    }
    
    func showPicker(with type: UIImagePickerController.SourceType, for item: UnreportedDamageCellViewModel) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = type
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.delegate = self
            
            // No reason to make router or smth like that, so...
            guard let controller = UIApplication.shared.keyWindow?.rootViewController else { return }
            controller.present(imagePicker, animated: true, completion: nil)
            
            self.editingLocation = item.damageLocation
        }
    }
    
    func showSettingsAlert(message: String) {
        let settingsAction = AlertAction(title: L10n.AlertAction.openSettings, style: .default) {
            UIApplication.open(url: UIApplication.openSettingsURLString)
        }
        
        UIAlertController.show(actions: [settingsAction, .cancel()],
                               title: L10n.AlertTitle.permissionDenied,
                               message: message, style: .alert)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension UnreportedDamagesViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage,
            let damageLocation = editingLocation {
            
            let uploadableImage = UploadableImage(image: image)
            upload(image: uploadableImage, for: damageLocation)
            
            var photos = self.photos.value
            photos[damageLocation] = uploadableImage
            self.photos.accept(photos)
        }
        
        picker.dismiss(animated: true, completion: nil)
        editingLocation = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        editingLocation = nil
    }

}

// MARK: - Api interaction

private extension UnreportedDamagesViewModel {
    func upload(image: UploadableImage, for location: DamageLocation) {
        let single = apiService.upload(image: image, title: location.title)
        image.observeUploading(single)
    }

    func validate(comment: String?,
                  photos: [DamageLocation :UploadableImage]?,
                  uploadingsIsInProcess: Bool) -> Single<UnreportedDamages> {
        guard let comment = comment, !comment.isEmpty else {
            return .error(error: .noComment)
        }
        
        guard photosIsUploading.value == false else {
            return .error(error: .imageIsUploading)
        }
        
        var hashes = [String]()
        var locations = [String]()

        if let photos = photos {
            for (key, value) in photos {
                guard let hash = value.remoteHash.value else { continue }
                hashes.append(hash)
                locations.append(key.title)
            }
        }
        
        guard hashes.count == photos?.count else {
            return .error(error: .imageUploadFalied)
        }
        
        let description = "Damage locations:\n- \(locations.joined(separator: "\n- "))"
        let damages = UnreportedDamages(title: comment, description: description, photos: hashes)
        return .just(damages)
    }
    
    func upload(damages: UnreportedDamages) -> Single<Void> {
        loadingState.accept(.loading)
        return damages.toDictionary()
            .map { parameters in
                 SaveDamagesRequest(parameters: parameters)
            }
            .flatMap {[weak self] request -> Single<SavedAlbumData?>in
                guard let self = self else { return .just(nil) }
                return self.apiService.send(request: request,
                                            decoder: APIDataDecoder<SavedAlbumData>())
                    .asSingle()
                    .map{ $0 }
            }
            .do(onSuccess: {[weak self] albumData in
                guard let self = self else { return }
                self.loadingState.accept(.loaded(.success))
                self.albumSaved(id: albumData?.id)
            }, onError: { [weak self] error in
                self?.loadingState.accept(.loaded(.failed(error: error)))
            })
            .map{ _ in () }
    }
    
    // Clean photos and open saved album in brower
    func albumSaved(id: String?) {
        guard let id = id else { return }
        
        let url = "https://imgur.com/a/\(id)"
        UIApplication.open(url: url)
        
        photos.accept([:])
        comment.accept(nil)
    }
}

private extension Single {
    static func error(error: UnreportedDamagesViewModelError) -> Single<Element> {
        return .error(error)
    }
}

