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
        
        self.title = "設定"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる", style: .Plain, target: self, action: "onClickClose")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}