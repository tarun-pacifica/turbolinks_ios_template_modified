//
//  UIViewController+IsModal.swift
//  Stockland
//
//  Created by Mark Biegel on 4/1/17.
//  Copyright © 2017 Stockland. All rights reserved.
//

import UIKit

extension UIViewController {
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        }
        
        if self.presentingViewController?.presentedViewController == self {
            return true
        }
        
        if self.navigationController != nil && self.navigationController?.presentingViewController?.presentedViewController == self.navigationController {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }

        return false
    }
}
