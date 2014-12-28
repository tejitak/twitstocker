//
//  LoginViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2014/12/28.
//  Copyright (c) 2014年 Takuya Tejima. All rights reserved.
//

import Foundation
import TwitterKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let logInButton = TWTRLogInButton(logInCompletion: {
            (session: TWTRSession!, error: NSError!) in
            if session != nil {
                UIApplication.sharedApplication().keyWindow?.rootViewController = MainTabViewController()
//                UIApplication.sharedApplication().keyWindow?.rootViewController = TimelineViewController()
            } else {
                println(error.localizedDescription)
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
    }
}