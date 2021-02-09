//
//  NibLoadable.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable {
    static var nibName: String {
        return String(describing: self)
    }
}
