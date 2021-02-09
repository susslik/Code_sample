//
//  ApiUploadRequest.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 07.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Alamofire

protocol ApiUploadRequest: ApiRequest {
    var data: Data { get }
    var dataName: String { get }
    var mimeType: String { get }
    var fileName: String { get }
}

struct ImageUploadRequest: ApiUploadRequest {
    let data: Data
    let dataName: String = "image"
    let mimeType: String = "image/jpeg"
    let fileName: String = "fileName"
    
    let httpMethod: HTTPMethod = .post
    let apiMethod: String = "image"
    let contentType: [String] = [jsonType]
    
    let parameters: Parameters?
    
    init(data: Data, title: String) {
        self.data = data
        parameters = ["type":"file", "tilte": title, "description": ""]
    }
}
