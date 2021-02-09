//
//  HudView.swift
//  Code_sample
//
//  Created by Sergey Blazhko on 04.02.2020.
//  Copyright © 2020 Sergey Blazhko. All rights reserved.
//

import MBProgressHUD

protocol HudView {
    func showHud(withTitle title: String?, subtitle: String?)
    func hideHud(completion: EmptyCallback?)
}

extension HudView where Self: UIViewController {
    private var hudTag: Int { return 0x517 }
    private func hud(shouldCreate: Bool) -> MBProgressHUD? {
        if let hud = view.viewWithTag(hudTag) as? MBProgressHUD {
            return hud
        }

        guard shouldCreate else { return nil }

        let hud = MBProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        hud.bezelView.backgroundColor = .gray
        hud.contentColor = .white
        hud.tag = hudTag
        hud.backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.3)

        view.addSubview(hud)

        return hud
    }

    func showHud(withTitle title: String? = nil, subtitle: String? = nil) {
        DispatchQueue.main.async {
            guard let hud = self.hud(shouldCreate: true) else { return }
            hud.label.text = title
            hud.detailsLabel.text = subtitle
            hud.show(animated: true)
        }
    }

    func hideHud(completion: EmptyCallback? = nil) {
        DispatchQueue.main.async {
            guard let hud = self.hud(shouldCreate: false) else {
                completion?()
                return
            }
            hud.completionBlock = completion
            hud.hide(animated: true)
        }
    }
}
