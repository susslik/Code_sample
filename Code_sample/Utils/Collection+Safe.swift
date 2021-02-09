//
//  Collection+Safe.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 06.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
