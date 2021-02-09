//
//  Loadable.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

protocol Loadable {
    func loadingStarted()
    func loadingFinished(state: LoadedState)
}
