//
//  LoadableView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.

import Toast_Swift

protocol LoadableView: AnyObject, Loadable {
    var toastPosition: ToastPosition { get }
}

extension LoadableView {
    var toastPosition: ToastPosition {
        return .top
    }

    func loadingStarted() {
        if let hudView = self as? HudView {
            hudView.showHud(withTitle: nil, subtitle: nil)
        }
    }

    func loadingFinished(state: LoadedState) {
        loadingFinished(state: state, completion: nil)
    }

    func loadingFinished(state: LoadedState, completion: EmptyCallback?) {
        guard let hudView = self as? HudView else {
            showToastIfNeeded(state: state, completion: completion)
            return
        }
        
       if case .failed = state {
           hudView.hideHud { [weak self] in
               self?.showToastIfNeeded(state: state, completion: completion)
           }
       } else {
           hudView.hideHud(completion: completion)
       }

    }

    func showToastIfNeeded(state: LoadedState, completion: EmptyCallback?) {
        if let toast = self as? ToastView, case let .failed(error) = state {
            let message = error.userPresentableDescription
            toast.show(message: message, withTitle: nil, position: toastPosition) { _ in completion?() }
        } else {
            completion?()
        }
    }
}
