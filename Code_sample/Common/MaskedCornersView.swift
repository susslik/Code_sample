//
//  MaskedCornersView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 05.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

protocol MaskedCornersView {
    func mask(except: CACornerMask?, radius: CGFloat)
}

extension UIView: MaskedCornersView {
    func mask(except: CACornerMask?, radius: CGFloat) {
        var cornersToMask: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                           .layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        if let except = except, !except.isEmpty {
            cornersToMask.subtract(except)
        }

        layer.maskedCorners = cornersToMask
        layer.cornerRadius = radius
    }
}
