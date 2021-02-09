//
//  UnreportedDamagesViewController.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 03.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class UnreportedDamagesViewController: LoadableViewController, ToastView, HudView {
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var commentTextField: UITextField?
    
    @IBOutlet weak var nextButton: StateColorButton?
    
    var viewModel: UnreportedDamagesViewModel?
    
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupStrings()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
}

private extension UnreportedDamagesViewController {
    func setupViews() {
        let imageView = UIImageView(image: Asset.navBarTitleImage.image)
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView

        collectionView?.allowsSelection = true
        collectionView?.allowsMultipleSelection = false
        collectionView?.register(UnreportedDamageCell.self)

        nextButton?.mask(except: nil, radius: 8)
        nextButton?.clipsToBounds = false
        nextButton?.layer.shadowOpacity = 1.0
        nextButton?.layer.shadowColor = Asset.elementBackgroundColor.color.withAlphaComponent(0.5).cgColor
        nextButton?.layer.shadowRadius = 2
        nextButton?.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    func setupStrings() {
        titleLabel?.text = L10n.UnreportedDamages.title
        commentTextField?.placeholder = L10n.commentPlaceholder
        nextButton?.setTitle(L10n.nextButtonTitle, for: .normal)
    }
    
    func setupBindings () {
        guard
            let viewModel = viewModel,
            let collectionView = collectionView,
            let nextButton = nextButton
        else {
            return
        }

        viewModel.setupBindings(with: disposeBag)

        let cellId = UnreportedDamageCell.reuseIdentifier
        let cellType = UnreportedDamageCell.self
        viewModel.items
            .bind(to: collectionView.rx.items(cellIdentifier: cellId,
                                              cellType: cellType)) { [weak self] _, cellViewModel, cell  in
                    self?.setup(cell: cell, with: cellViewModel)
            }
       .disposed(by: disposeBag)

        collectionView.rx.itemSelected
            .bind { [weak viewModel] indexPath in
                viewModel?.editImage(at: indexPath)
            }
            .disposed(by: disposeBag)

        viewModel.loadingState
            .bind(to: rx.loadingState)
            .disposed(by: disposeBag)

        viewModel.canContinue
            .map { $0 }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        commentTextField?.rx
            .controlEvent(.editingDidEndOnExit)
            .bind(onNext: {[weak commentTextField] in
                commentTextField?.endEditing(true)
            })
        .disposed(by: disposeBag)
        
        commentTextField?.rx.text
            .bind(to: viewModel.comment)
            .disposed(by: disposeBag)

        nextButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.commentTextField?.endEditing(true)
                self.viewModel?.onNextPressed()
                    .subscribe(onSuccess: { [weak self] in
                        self?.commentTextField?.text = nil
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
    }
    
    func setup(cell: UnreportedDamageCell, with cellViewModel: UnreportedDamageCellViewModel) {
        cell.setup(viewModel: cellViewModel)
        cell.retryPressed?
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.retryUploading(for: cellViewModel)
            })
            .disposed(by: cell.disposeBag)
        
        cell.deleteButton?.rx.tap
            .bind(onNext: { [weak viewModel] _ in
                viewModel?.deleteImage(for: cellViewModel)
            })
            .disposed(by: cell.disposeBag)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension UnreportedDamagesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let cellSpacing = layout.minimumInteritemSpacing
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let side = (collectionView.bounds.width - cellSpacing - insets) / 2
        return CGSize(width: side, height: side)
    }
}
