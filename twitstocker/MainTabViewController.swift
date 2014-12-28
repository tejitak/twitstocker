//
//  MainTabViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class MainTabViewController: UITabBarController {
    
    var firstView: TimelineViewController!
    var secondView: FavoriteViewController!
    var session: TWTRSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView = TimelineViewController()
        secondView = FavoriteViewController()
        
        firstView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 1)
        secondView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Bookmarks, tag: 2)
        
        var firstNavigationController = UINavigationController(rootViewController: firstView)
        var secondNavigationController = UINavigationController(rootViewController: secondView)
        
        self.setViewControllers([firstNavigationController, secondNavigationController], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}