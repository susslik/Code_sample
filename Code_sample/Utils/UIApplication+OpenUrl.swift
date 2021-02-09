//
//  UIApplication+OpenUrl.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 09.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import UIKit

extension UIApplication {
    static func open(url: String?) {
        guard
            let url = url,
            let link = URL(string: url),
            UIApplication.shared.canOpenURL(link)
        else {
            return
        }
        UIApplication.shared.open(link, options: [:],
                                  completionHandler: nil)
    }
}
