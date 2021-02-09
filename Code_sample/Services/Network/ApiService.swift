//
//  ApiService.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 07.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Alamofire
import RxAlamofire
import RxSwift

let jsonType = "application/json"

private let okStatusCodes = 200 ..< 300
private let authorizationHeader = "Authorization"

enum ApiServiceError: Error {
    case imageDataError
}

class APIDataDecoder<T: Decodable> {
    func decode(_ data: Data) throws -> ApiResponse<T> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(ApiResponse<T>.self, from: data)
    }
}

class ApiService {
    private let apiBaseURL: String
    
    private let tokenPrefix: String
    private let token: String
   
    private lazy var headers: [String: String] = {
        return [authorizationHeader: "\(tokenPrefix) \(token)"]
    }()

    init(apiBaseURL: String, tokenPrefix: String, token: String) {
        self.apiBaseURL = apiBaseURL
        self.tokenPrefix = tokenPrefix
        self.token = token
    }

    func send<T>(request: ApiRequest, decoder: APIDataDecoder<T>) -> Observable<T> {
        let url = "\(apiBaseURL)\(request.apiMethod)"
        let identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        
        return RxAlamofire
            .request(request.httpMethod, url, parameters: request.parameters, encoding: request.encoding, headers: headers)
            .validateWithDetailedErrors(statusCode: okStatusCodes)
            .validate(contentType: request.contentType)
            .responseData()
            .map { _, data in
                let response = try decoder.decode(data)
                guard let data = response.data else {
                   let error = NSError(domain: "ApiRequestError", code: response.status, userInfo: nil)
                   ApiService.reportError(error, request: request)
                   throw error
               }
                return data
            }
            .do(onError: { ApiService.reportError($0, request: request) },
                onDispose: { UIApplication.shared.endBackgroundTask(identifier) })
    }
    
    func upload(image: UploadableImage, title: String) -> Observable<Void> {
        guard let data = image.image.compressedData else {
            return .error(ApiServiceError.imageDataError)
        }

        image.uploadingState.accept(.loading)
        
        let request = ImageUploadRequest(data: data, title: title)
        return upload(request: request, decoder: APIDataDecoder<UploadedImageData>())
            .map { ($0.0, Double($0.1.completed)) }
            .do(onNext: { [weak image] in
                    image?.uploadProgress.accept($0.1)
                },
                onError: { [weak image] error in
                image?.uploadingState.accept(.loaded(.failed(error: error)))
            })
            .compactMap { [weak image] response, _ in
                guard let response = response else { return nil }
                
                guard let imageData = response.data else {
                    let error = NSError(domain: "ImageUploadError", code: response.status, userInfo: nil)
                    image?.uploadingState.accept(.loaded(.failed(error: error)))
                    ApiService.reportError(error, request: request)
                    throw error
                }
                
                image?.remoteUrl.accept(imageData.link)
                image?.remoteHash.accept(imageData.deletehash)

                image?.uploadingState.accept(.loaded(.success))

                return ()
            }
    }
    
    private static func reportError(_ error: Error, request: ApiRequest) {
        let error = error as NSError
        guard error.code != -999 else { return } //skip cancelled errors
        let newError = NSError(domain: error.domain,
                               code: error.code,
                               userInfo: [
                                   "httpMethod": request.httpMethod,
                                   "apiMethod": request.apiMethod,
                                   "parameters": request.parameters ?? [:],
                                   "encoding": request.encoding,
                                   "description": error.localizedDescription
                               ])

        ErrorLogger.shared.record(error: newError)
    }

}

// - MARK: Uploading

private extension ApiService {
    func upload<T>(request: ApiUploadRequest, decoder: APIDataDecoder<T>) -> Observable<(ApiResponse<T>?, RxProgress)> {
        let identifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        let url = "\(apiBaseURL)\(request.apiMethod)"

        return upload(request: request, to: url)
            .validateWithDetailedErrors(statusCode: okStatusCodes)
            .validate(contentType: request.contentType)
            .flatMap { request -> Observable<(Data?, RxProgress)> in
                let dataPart = request.rx
                    .responseData()
                    .map { _, d -> Data? in d }
                    .startWith(nil as Data?)

                let progressPart = request.rx.progress()
                return Observable.combineLatest(dataPart, progressPart) { ($0, $1) }
            }
            .map { data, progress -> (ApiResponse<T>?, RxProgress) in
                if let data = data {
                    return (try decoder.decode(data), progress)
                } else {
                    return (nil, progress)
                }
            }
            .do(onError: { ApiService.reportError($0, request: request) },
                onDispose: { UIApplication.shared.endBackgroundTask(identifier) })
    }

    func upload(request: ApiUploadRequest, to url: String) -> Observable<UploadRequest> {
        return .create { observer in
            var uploadRequest: UploadRequest?
            Alamofire.upload(
                multipartFormData: { multipartFormData in
                    if let parameters = request.parameters as? [String: String]{
                        for (key, value) in parameters {
                            guard let data = value.data(using: .utf8) else { continue }
                            multipartFormData.append(data, withName: key)
                        }
                    }
                    multipartFormData.append(request.data, withName: request.dataName, fileName: request.fileName, mimeType: request.mimeType)
                },
                to: url,
                method: request.httpMethod,
                headers: self.headers,
                encodingCompletion: { result in
                    switch result {
                    case let .success(request, _, _):
                        uploadRequest = request
                        observer.onNext(request)
                    case let .failure(error):
                        uploadRequest = nil
                        observer.onError(error)
                    }
                }
            )

            return Disposables.create {
                uploadRequest?.cancel()
            }
        }
    }
}

// - MARK: Response validation

private extension ObservableType where Element: DataRequest {
    func validateWithDetailedErrors<S: Sequence>(statusCode: S) -> RxSwift.Observable<Element> where S.Element == Int {
        return map { $0.validateWithDetailedErrors(statusCode: statusCode) }
    }
}

private extension ObservableType where Element: UploadRequest {
    func responseData() -> Observable<(HTTPURLResponse, Data)> {
        return flatMap { $0.rx.responseData() }
    }

    func validate<S: Sequence>(contentType acceptableContentType: S) -> Observable<Element> where S.Iterator.Element == String {
        return map { $0.validate(contentType: acceptableContentType) }
    }
}

private extension DataRequest {
    @discardableResult
    func validateWithDetailedErrors<S: Sequence>(statusCode acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int {
        return validate { [unowned self] _, response, bodyData in
            self.validate(statusCode: acceptableStatusCodes, response: response, bodyData: bodyData)
        }
    }

    func validate<S: Sequence>(statusCode acceptableStatusCodes: S, response: HTTPURLResponse, bodyData: Data?)
        -> ValidationResult where S.Iterator.Element == Int {
        if acceptableStatusCodes.contains(response.statusCode) {
            return .success
        }
            
        let reason = AFError.ResponseValidationFailureReason.unacceptableStatusCode(code: response.statusCode)
        let error: Error = AFError.responseValidationFailed(reason: reason)
        return .failure(error)
    }
}
