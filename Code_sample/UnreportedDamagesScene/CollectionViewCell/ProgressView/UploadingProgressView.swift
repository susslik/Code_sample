//
//  UploadingProgressView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 05.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

import RxRelay

private let progressSide: CGFloat = 50

class UploadingProgressView: UIView {
    private lazy var progressView: CircularProgressView = {
        let progressView = CircularProgressView(frame: .zero)
        addSubview(progressView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([progressView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     progressView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     progressView.widthAnchor.constraint(equalToConstant: progressSide),
                                     progressView.heightAnchor.constraint(equalToConstant: progressSide)])

        return progressView
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Asset.retryButtonIcon.image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(onRetryPressed), for: .touchUpInside)

        addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: centerXAnchor),
                                     button.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     button.widthAnchor.constraint(equalToConstant: progressSide),
                                     button.heightAnchor.constraint(equalToConstant: progressSide)])

        return button
    }()

    let retryPressed = PublishRelay<Void>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }

    private func setupAppearance() {
        backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    }

    // Actions
    @objc private func onRetryPressed() {
        retryPressed.accept(())
    }

    func update(progress: Double) {
        progressView.set(progress: progress)
    }

    func setupForLoading() {
        progressView.isHidden = false
        retryButton.isHidden = true
        isUserInteractionEnabled = true
    }

    func setupForError() {
        progressView.isHidden = true
        retryButton.isHidden = false
        isUserInteractionEnabled = true
    }

    func setupForSuccess() {
        isUserInteractionEnabled = false
    }
}
