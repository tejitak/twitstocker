//
//  SettingViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/05.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController {

    var closeBtn: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Setting"
        
        self.view.backgroundColor = UIColor.cyanColor()

        let closeBtn = UIButton(frame: CGRectMake(0, 0, 100, 100))
        closeBtn.setTitle("Close", forState: .Normal)
        closeBtn.addTarget(self, action: "onClickClose", forControlEvents: .TouchUpInside)
        self.view.addSubview(closeBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}