//
//  StateColorButton.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 10.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

@IBDesignable
class StateColorButton: UIButton {
    @IBInspectable var normalBackgroundColor: UIColor = Asset.disabledElementBackgroundColor.color {
        didSet { updateBackgroundColor() }
    }

    @IBInspectable var disabledBackgroundColor: UIColor = Asset.elementBackgroundColor.color {
        didSet { updateBackgroundColor() }
    }

    override var isEnabled: Bool {
        didSet { updateBackgroundColor() }
    }

    private func updateBackgroundColor() {
        if state == .disabled {
            backgroundColor = disabledBackgroundColor
        } else {
            backgroundColor = normalBackgroundColor
        }
    }
}
