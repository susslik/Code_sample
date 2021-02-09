//
//  ToastView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.

import Toast_Swift

typealias ToastCompletion = ((_ isTapped: Bool) -> Void)

protocol ToastView {
    func show(message: String?, withTitle title: String?,
              position: ToastPosition, completion: ToastCompletion?)
}

extension ToastView {
    func show(message: String, withTitle title: String? = nil, completion: ToastCompletion? = nil) {
        show(message: message, withTitle: title, position: .top, completion: completion)
    }
}

extension ToastView where Self: UIViewController {
    func show(message: String?, withTitle title: String? = nil, position: ToastPosition = .top, completion: ToastCompletion? = nil) {
        DispatchQueue.main.async {
            self.view.makeToast(message, position: position, title: title, completion: completion)
        }
    }
}
