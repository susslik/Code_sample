//
//  ApiResponse.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 10.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

struct ApiResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    
    let data: T?
}

struct UploadedImageData: Decodable {
    let link: String
    let deletehash: String
}

struct SavedAlbumData: Decodable {
    let id: String
}
