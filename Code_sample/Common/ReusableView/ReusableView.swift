//
//  ReusableView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

protocol ReusableView: UIView {
    static var reuseIdentifier: String { get }
}

extension UICollectionReusableView: ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
