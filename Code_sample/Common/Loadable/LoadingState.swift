//
//  LoadingState.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import Foundation

enum LoadingState {
    case none
    case loading
    case loaded(LoadedState)
}

enum LoadedState {
    case success
    case failed(error: Error)
}
