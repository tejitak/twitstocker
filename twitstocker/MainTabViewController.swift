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
        timelineView.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar-article", comment: ""), image: UIImage(named: "tabbar-article.png"), selectedImage: UIImage(named: "tabbar-article.png"))
        favoriteView.tabBarItem = UITabBarItem(title: NSLocalizedString("tabbar-favorite", comment: ""), image: UIImage(named: "tabbar-favorite.png"), selectedImage: UIImage(named: "tabbar-favorite.png"))
        
        var timelineNavigationController = UINavigationController(rootViewController: timelineView)
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