//
//  UploadableImage.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import RxCocoa
import RxSwift

// Class instead of struct to use weak refences
// At uploading closures 
class UploadableImage {
    let image: UIImage

    let remoteHash: BehaviorRelay<String?> = .init(value: nil)
    let remoteUrl: BehaviorRelay<String?> = .init(value: nil)
    let uploadProgress: BehaviorRelay<Double> = .init(value: 0)
    var isUploaded: Bool { return remoteUrl.value != nil }
    
    let isUploading: BehaviorRelay<Bool> = .init(value: false)
    let uploadingState: BehaviorRelay<LoadingState> = .init(value: .none)

    private let disposeBag = DisposeBag()

    init(image: UIImage) {
        self.image = image
        
        uploadingState
            .map {
                if case .loading = $0 { return true }
                return false
            }
            .bind(to: isUploading)
            .disposed(by: disposeBag)
    }
    
    // Wait for uploading finish
    func observeUploading(_ observable: Observable<Void>) {
        observable.subscribe { _ in }
            .disposed(by: disposeBag)
    }
}
