//
//  UICollectionView+Reusable.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) where T: NibLoadable {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
}
