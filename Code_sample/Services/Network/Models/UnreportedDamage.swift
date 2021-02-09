//
//  UnreportedDamage.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 07.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

struct UnreportedDamages: Encodable {
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case photos = "deletehashes"
    }
    
    let title: String
    let description: String
    let photos: [String]?
}
