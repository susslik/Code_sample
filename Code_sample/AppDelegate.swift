//
//  AppDelegate.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 03.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit
import AlamofireNetworkActivityIndicator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NetworkActivityIndicatorManager.shared.isEnabled = true

        setupAppearance()
        setupController()
        return true
    }
}

private extension AppDelegate {
    func setupAppearance() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = .white
        appearance.tintColor = .white
    }
    
    // Just single view application
    // No reason to create some routers
    // And also no reason to setup environments and configs
    // With Api endpoits and tokens
    func setupController() {
        let apiService = ApiService(apiBaseURL: "https://api.imgur.com/3/", tokenPrefix: "Client-ID", token: "1d58831bd7ce5ea")
        let viewController = StoryboardScene.Main.unreportedDamagesViewController.instantiate()
        viewController.viewModel = UnreportedDamagesViewModel(apiService: apiService)
        
        let navController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navController
    }
}
