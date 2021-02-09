//
//  UserPresentableError.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

protocol UserPresentableError: LocalizedError {
    var userPresentable: Bool { get }
    var userPresentableDescription: String? { get }
}

extension Error {
    #if DEBUG
        var userPresentableDescription: String? {
            return localizedDescription
        }

    #else
        var userPresentableDescription: String? {
            if let presentableError = self as? UserPresentableError,
                presentableError.userPresentable {
                return presentableError.localizedDescription
            }

            return "Ooopss.. Something went wrong"
        }
    #endif
}
