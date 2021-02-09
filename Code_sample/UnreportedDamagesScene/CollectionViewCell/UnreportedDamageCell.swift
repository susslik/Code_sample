//
//  UnreportedDamageCell.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

import RxSwift
import RxRelay

class UnreportedDamageCell: UICollectionViewCell, NibLoadable {
    @IBOutlet weak var contentBackgroundView: UIView?
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var progressView: UploadingProgressView?
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var deleteButton: UIButton?
    
    var retryPressed: PublishRelay<Void>? { return progressView?.retryPressed }

    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func setupViews() {
        mask(except: nil, radius: 16)
        clipsToBounds = false
        layer.shadowOpacity = 1.0
        layer.shadowColor = Asset.secondaryElementBackgroundColor.color.withAlphaComponent(0.75).cgColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 1)

        contentBackgroundView?.mask(except: nil, radius: 16)
        imageView?.mask(except: nil, radius: 16)
        progressView?.mask(except: nil, radius: 16)
        
        deleteButton?.mask(except: nil, radius: 16)
    }
    
    func setup(viewModel: UnreportedDamageCellViewModel) {
        titleLabel?.text = viewModel.title
        setup(image: viewModel.image)
    }
    
    private func setup(image: UploadableImage?) {
        guard let image = image else {
            imageView?.image = Asset.damagePlaceholder.image
            imageView?.contentMode = .scaleAspectFit
            deleteButton?.isHidden = true
            progressView?.isHidden = true
            return
        }

        imageView?.image = image.image
        imageView?.contentMode = .scaleAspectFill
        deleteButton?.isHidden = false
        
        image.uploadProgress
            .asDriver()
            .drive(onNext: { [weak progressView] progress in
                progressView?.update(progress: progress)
            })
            .disposed(by: disposeBag)

          image.uploadingState
              .asDriver()
              .drive(onNext: { [weak progressView] state in
                  switch state {
                  case .none:
                      progressView?.isHidden = true
                  case .loading:
                      progressView?.isHidden = false
                      progressView?.setupForLoading()
                  case .loaded(.success):
                      progressView?.isHidden = true
                      progressView?.setupForSuccess()
                  case .loaded(.failed):
                      progressView?.isHidden = false
                      progressView?.setupForError()
                  }
              })
              .disposed(by: disposeBag)
    }

}

