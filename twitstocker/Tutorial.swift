//
//  SettingViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/05.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: UIViewController {
    
    var closeBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tutorial"
        
        self.view.backgroundColor = UIColor.yellowColor()
        
        let closeBtn = UIButton(frame: CGRectMake(0, 0, 100, 100))
        closeBtn.backgroundColor = UIColor.redColor()
        closeBtn.addTarget(self, action: "onClickClose", forControlEvents: UIControlEvents.TouchUpInside)
        closeBtn.center = self.view.center
        self.view.addSubview(closeBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}