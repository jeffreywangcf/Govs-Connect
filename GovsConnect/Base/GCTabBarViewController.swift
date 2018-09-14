//
//  GCTabBarViewController.swift
//  GovsConnect
//
//  Created by Spring on 2018/6/20.
//  Copyright © 2018年 Eagersoft. All rights reserved.
//  项目的标签栏控制器

import UIKit

class GCTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColorFromRGB(rgbValue: 0xBABABA, alpha: 1)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:APP_THEME_COLOR], for: .selected)
        
        //给标签栏控制器添加子控制器
        let postVc = PostsViewController(nibName: "PostsViewController", bundle: nil)
        NotificationCenter.default.addObserver(postVc, selector: #selector(postVc.loginAction(_:)), name: AppIOManager.loginActionNotificationName, object: nil)
        self.addChildController(childVc: postVc, title: "Posts", imageName: "", selImage: "")
        
        //发现控制器
        let disVc = DiscoverViewController()
        self.addChildController(childVc: disVc, title: "Discover", imageName: "", selImage: "")
        
        //lookUp
        let lookUpVc = LookupViewController()
        NotificationCenter.default.addObserver(lookUpVc, selector: #selector(lookUpVc.loginAction(_:)), name: AppIOManager.loginActionNotificationName, object: nil)
        self.addChildController(childVc: lookUpVc, title: "Look up", imageName: "", selImage: "")
        
        //notification
//        let notificationVC = NotificationViewController()
//        self.addChildController(childVc: notificationVC, title: "Notification", imageName: "", selImage: "")
        
        //You
        let youVc = YouViewController()
        NotificationCenter.default.addObserver(youVc, selector: #selector(youVc.loginAction(_:)), name: AppIOManager.loginActionNotificationName, object: nil)
        self.addChildController(childVc: youVc, title: "You", imageName: "", selImage: "")
    }

    func addChildController(childVc:UIViewController, title:String, imageName:String, selImage:String) -> Void {
        childVc.title = title
        childVc.tabBarItem.image = UIImage.init(named: imageName)
        childVc.tabBarItem.selectedImage = UIImage.init(named: selImage)?.withRenderingMode(.alwaysOriginal)
        let nav = GCNavigationViewController.init(rootViewController: childVc)
        nav.navigationBar.barStyle = .default
        nav.navigationBar.barTintColor = APP_THEME_COLOR
        nav.navigationBar.tintColor = UIColor.white
        nav.navigationBar.isTranslucent = false
        self.addChildViewController(nav)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

}
