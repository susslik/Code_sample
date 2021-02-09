//
//  UIAlert+Extension.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 06.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

typealias EmptyCallback = (() -> Void)

extension UIAlertController {
    convenience init(title: String? = nil, message: String? = nil,
                     style: UIAlertController.Style) {
        self.init(title: title, message: message, preferredStyle: style)
    }

    static func show(actions: [AlertAction], title: String? = nil,
                     message: String? = nil, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, style: style)
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style,
                                        handler: { _ in
                alert.resignFirstResponder()
                action.handler?()
            })
            alert.addAction(alertAction)
        }

        DispatchQueue.main.async {
            guard let controller = UIApplication.shared.keyWindow?.rootViewController else { return }
            controller.present(alert, animated: true, completion: nil)
        }
    }
}

struct AlertAction {
    static func cancel(_ handler: EmptyCallback? = nil) -> AlertAction {
        return AlertAction(title: L10n.AlertAction.cancel,
                              style: .cancel, handler: handler)
    }
    
    let title: String
    let style: UIAlertAction.Style
    let handler: EmptyCallback?

    init(title: String, style: UIAlertAction.Style = .default, handler: EmptyCallback? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
