//
//  CustomTabbarViewController.swift
//  Created by Mark Biegel on 4/1/17.
//

import UIKit

class CustomTabbarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let tab1 = TurbolinksNavigationController(url: K.URL.Tab1);
        tab1.tabBarItem = UITabBarItem.init(title: "", image: UIImage(named: "home_inactive")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "home_active")?.withRenderingMode(.alwaysOriginal))
        tab1.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        let tab2 = TurbolinksNavigationController(url: K.URL.Tab2);
        tab2.tabBarItem = UITabBarItem.init(title: "", image: UIImage(named: "about_inactive")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "about_active")?.withRenderingMode(.alwaysOriginal))
        tab2.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
//        let tab3 = TurbolinksNavigationController(url: K.URL.Tab3);
//        tab3.tabBarItem = UITabBarItem.init(title: "", image: UIImage(named: "firefox")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "firefox_active")?.withRenderingMode(.alwaysOriginal))
//        tab3.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
//        
//        let tab4 = TurbolinksNavigationController(url: K.URL.Tab4);
//        tab4.tabBarItem = UITabBarItem.init(title: "", image: UIImage(named: "safari")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "safari_active")?.withRenderingMode(.alwaysOriginal))
//        tab4.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
//
//        let tab5 = TurbolinksNavigationController(url: K.URL.Tab5);
//        tab5.tabBarItem = UITabBarItem.init(title: "", image: UIImage(named: "icecat")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "icecat_active")?.withRenderingMode(.alwaysOriginal))
//        tab5.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)

        
        self.setViewControllers([tab1, tab2], animated: false);
//        self.setViewControllers([tab1, tab2, tab3, tab4, tab5], animated: false);
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    func resetTabbar() {
        guard let viewControllers = self.viewControllers else {return}
        for vc : UIViewController in viewControllers {
            if let nav = vc as? TurbolinksNavigationController {
                nav.popToRootViewController(animated: false)
                nav.reset()
            }
        }
        let homeIndex = 0
        self.selectedIndex = homeIndex
    }
}
