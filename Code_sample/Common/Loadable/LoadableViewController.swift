//
//  LoadableViewController.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

typealias LoadableViewController = UIViewController & LoadableView

extension Reactive where Base: LoadableViewController {
    var loadingState: Binder<LoadingState> {
        // separated closure is used to prevent clang crash when compiling in release mode for archiving
        let binding: (LoadableViewController, LoadingState) -> Void = { target, value in
            switch value {
            case .none:
                break
            case .loading:
                target.loadingStarted()
            case let .loaded(state):
                target.loadingFinished(state: state)
            }
        }
        return Binder(base, binding: binding)
    }
}
