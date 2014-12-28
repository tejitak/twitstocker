//
//  MainTabViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit

class MainTabViewController: UITabBarController {
    
    var firstView: TimelineViewController!
    var secondView: FavoriteViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView = TimelineViewController()
        secondView = FavoriteViewController()
        
        firstView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 1)
        secondView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Bookmarks, tag: 2)
        
        var navigationController = UINavigationController(rootViewController: firstView);
        
        self.setViewControllers([navigationController, secondView!], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}