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

    var closeBtn: UIBarButtonItem?
    var hashtagInput: UITextField?
//    var noConfirmSwitch: 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる", style: .Plain, target: self, action: "onClickClose")
        // init config
        SettingStore.sharedInstance.load()
        let width = self.view.frame.size.width
        
        // hashtag
        let hashtagLabel: UILabel = UILabel(frame: CGRectMake(0, 100, 100, 50))
        hashtagLabel.backgroundColor = UIColor.redColor()
        hashtagLabel.text = "ハッシュタグ"
//        hashtagLabel.textAlignment = NSTextAlignment.Left
//        hashtagLabel.layer.position = CGPoint(x: 0, y: 100)
        self.view.addSubview(hashtagLabel)
        let hashtagInput = UITextField(frame: CGRectMake(100, 100, 200, 50))
        hashtagInput.borderStyle = UITextBorderStyle.RoundedRect
        hashtagInput.placeholder = "#あとで読む"
        hashtagInput.text = SettingStore.sharedInstance.getHashtag()
        self.hashtagInput = hashtagInput
        self.view.addSubview(hashtagInput)
        
        let hashtagDescription: UILabel = UILabel(frame: CGRectMake(20, 0, width - 40, 0))
        hashtagDescription.text = "説明文xxxx xx xxxx"
        hashtagDescription.backgroundColor = UIColor.redColor()
        hashtagDescription.layer.position = CGPoint(x: self.view.bounds.width/2,y: 160)
        hashtagDescription.numberOfLines = 0
        hashtagDescription.textAlignment = NSTextAlignment.Center
        hashtagDescription.sizeToFit()
        hashtagDescription.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.view.addSubview(hashtagDescription)
        
        // no confirm
        let noConfirmLabel: UILabel = UILabel(frame: CGRectMake(300, 0, 100, 50))
        noConfirmLabel.text = "スワイプ時の確認非表示"
        hashtagLabel.layer.position = CGPoint(x: 200, y: 50)
        hashtagLabel.backgroundColor = UIColor.redColor()
        self.view.addSubview(noConfirmLabel)
//        let noConfirmInput = UITextField(frame: CGRectMake(100, 100, 200, 50))
//        noConfirmInput.borderStyle = UITextBorderStyle.RoundedRect
//        noConfirmInput.placeholder = "#あとで読む"
//        noConfirmInput.text = SettingStore.sharedInstance.getNoConfirm()()
//        self.noConfirmSwitch = noConfirmInput
        
        
        // reset read data
        let restBtn: UIButton = UIButton(frame: CGRectMake(20, 400, width - 40, 40))
        restBtn.setTitle("既読データをリセット", forState: UIControlState.Normal)
        restBtn.backgroundColor = UIColor.redColor()
        restBtn.layer.cornerRadius = 8
        restBtn.addTarget(self, action: "onClickResetReadData", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(restBtn)
        
        // logout
        let logoutBtn: UIButton = UIButton(frame: CGRectMake(20, 460, width - 40, 40))
        logoutBtn.setTitle("Twitterログアウト", forState: UIControlState.Normal)
        logoutBtn.backgroundColor = UIColor.blueColor()
        logoutBtn.layer.cornerRadius = 8
        logoutBtn.addTarget(self, action: "onClickLogout", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickResetReadData(){
        ReadStore.sharedInstance.resetAllReadData()
        // TODO: reload timeline
        
    }
    
    func onClickLogout() {
        // TODO: show login dialog
        
    }
    
    func onClickClose() {
        // save data
        SettingStore.sharedInstance.saveHashtag(self.hashtagInput?.text)
        dismissViewControllerAnimated(true, completion: nil)
    }
}