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
    
    var timelineView: TimelineViewController!
    var favoriteView: FavoriteViewController!
    var session: TWTRSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize local stored core data
        ReadStore.sharedInstance.resetAllReadData()
        ReadStore.sharedInstance.load()
        // init config
        SettingStore.sharedInstance.load()
        
        timelineView = TimelineViewController()
        favoriteView = FavoriteViewController()
        // register callback on favorite
        timelineView.onFavorite = {() -> () in
            self.favoriteView.needReload = true
        }
        favoriteView.onUnFavorite = {() -> () in
            self.timelineView.needReload = true
        }
        
        timelineView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Recents, tag: 1)
        favoriteView.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Favorites, tag: 2)
        
        var timelineNavigationController = UINavigationController(rootViewController: timelineView)
//        timelineNavigationController.navigationBar.barTintColor = UIColor.whiteColor()
        var favoriteNavigationController = UINavigationController(rootViewController: favoriteView)
        self.setViewControllers([timelineNavigationController, favoriteNavigationController], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func removeFromParentViewController() {
        self.timelineView?.view?.removeFromSuperview()
        self.timelineView?.removeFromParentViewController()
        self.favoriteView?.view?.removeFromSuperview()
        self.favoriteView?.removeFromParentViewController()
        super.removeFromParentViewController()
    }
}