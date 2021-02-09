//
//  ApiRequest.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 07.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Alamofire
import RxSwift

protocol ApiRequest {
    var httpMethod: HTTPMethod { get }
    var apiMethod: String { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var contentType: [String] { get }
}

extension ApiRequest {
    var encoding: ParameterEncoding { URLEncoding.default }
}

struct SaveDamagesRequest: ApiRequest {
    let httpMethod: HTTPMethod = .post
    let apiMethod: String = "album"
    let parameters: Parameters?
    let contentType: [String] = [jsonType]
}

extension Encodable {
    func toDictionary() -> Single<Parameters?> {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return .just(json)
        } catch {
            return .error(error)
        }
    }
}
