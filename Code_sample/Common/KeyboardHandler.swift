//
//  KeyboardHandler.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 09.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

protocol KeyboardHandler {
    func registerKeyboardNotifications()
    func unregisterKeyboardNotifications()
    func keyboardWillChangeFrame(to newFrame: CGRect,
                                 with duration: TimeInterval,
                                 options: UIView.AnimationOptions)
}

extension KeyboardHandler {
    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillChangeFrameNotification,
                                                  object: nil)
    }

    func keyboardWillChangeFrame(notification: NSNotification) {
        guard let endFrame = notification.keyboardEndFrame else {
            return
        }

        let duration = notification.keyboardAnimationDuration
        let animationOptions = notification.keyboardAnimationOptions
        keyboardWillChangeFrame(to: endFrame, with: duration, options: animationOptions)
    }
}

extension UIViewController: KeyboardHandler {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleKeyboardNotification),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    @objc func handleKeyboardNotification(_ notification: NSNotification) {
        keyboardWillChangeFrame(notification: notification)
    }

    @objc func keyboardWillChangeFrame(to newFrame: CGRect, with duration: TimeInterval,
                                       options: UIView.AnimationOptions) {
        let keyboardLocalFrame = view.convert(newFrame, from: nil)
        let viewFrame = view.frame
        let intersection = viewFrame.intersection(keyboardLocalFrame)
        let bottomInset = intersection.height

        additionalSafeAreaInsets.bottom = bottomInset
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension NSNotification {
    var keyboardAnimationDuration: TimeInterval {
        return (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.3
    }

    var keyboardAnimationOptions: UIView.AnimationOptions {
        let animationCurveRawNSN = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        return animationCurve
    }

    var keyboardEndFrame: CGRect? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }
}

