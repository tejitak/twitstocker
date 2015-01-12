//
//  SettingViewController.swift
//  twitstocker
//
//  Created by Takuya Tejima on 2015/01/05.
//  Copyright (c) 2015年 Takuya Tejima. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit

class SettingViewController: UIViewController {

    var onClose : (() -> Void)?
    
    var closeBtn: UIBarButtonItem?
    var hashtagInput: UITextField?
    var noConfirmSwitch: UISwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "設定"
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "閉じる", style: .Plain, target: self, action: "onClickClose")
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        // hashtag
        let hashtagLabel: UILabel = UILabel(frame: CGRectMake(20, 80, width - 40, 40))
        hashtagLabel.text = "ハッシュタグ"
        self.view.addSubview(hashtagLabel)
        
        let hashtagInput = UITextField(frame: CGRectMake(20, 120, width - 40, 40))
        hashtagInput.borderStyle = UITextBorderStyle.RoundedRect
        hashtagInput.placeholder = "#あとで読む"
        hashtagInput.text = SettingStore.sharedInstance.getHashtag()
        self.hashtagInput = hashtagInput
        self.view.addSubview(hashtagInput)
        
        let hashtagDescription: UILabel = UILabel(frame: CGRectMake(20, 170, width - 40, 0))
        hashtagDescription.text = "設定したハッシュタグを含むあなたのツイートを表示し、空欄の場合はURLを含むツイートを表示します\n\n※ただしTwitter APIの検索結果に依存するため、あなたの過去全てのTweetは表示されない可能性があります。"
        hashtagDescription.font = UIFont.systemFontOfSize(12)
        hashtagDescription.numberOfLines = 0
        hashtagDescription.textAlignment = NSTextAlignment.Left
        hashtagDescription.sizeToFit()
        hashtagDescription.lineBreakMode = NSLineBreakMode.ByCharWrapping
        self.view.addSubview(hashtagDescription)
        
        // no confirm
        let noConfirmLabel: UILabel = UILabel(frame: CGRectMake(20, 260, width - 120, 40))
        noConfirmLabel.text = "スワイプ時の確認非表示"
        self.view.addSubview(noConfirmLabel)
        let noConfirmSwitch = UISwitch(frame: CGRectMake(width - 80, 264, 100, 40))
        noConfirmSwitch.on = SettingStore.sharedInstance.isNoConfirm()
        self.noConfirmSwitch = noConfirmSwitch
        self.view.addSubview(noConfirmSwitch)
        
        // reset read data
        let restBtn: UIButton = UIButton(frame: CGRectMake(20, 330, width - 40, 40))
        restBtn.setTitle("既読データをリセット", forState: UIControlState.Normal)
        restBtn.backgroundColor = UIColor.redColor()
        restBtn.layer.cornerRadius = 8
        restBtn.addTarget(self, action: "onClickResetReadData", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(restBtn)
        
        // logout
        let logoutBtn: UIButton = UIButton(frame: CGRectMake(20, 390, width - 40, 40))
        logoutBtn.setTitle("Twitterログアウト", forState: UIControlState.Normal)
        logoutBtn.backgroundColor = UIColor.blueColor()
        logoutBtn.layer.cornerRadius = 8
        logoutBtn.addTarget(self, action: "onClickLogout", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(logoutBtn)
        
        // footer
        let footer: UILabel = UILabel(frame: CGRectMake(20, height - 60, width - 40, 40))
        footer.text = "TwitStocker version 1.0, 2015 created by tejitak"
        footer.adjustsFontSizeToFitWidth = true
        self.view.addSubview(footer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onClickResetReadData(){
        ReadStore.sharedInstance.resetAllReadData()
        // reload timeline after close
//        reset = true
        close(true)
    }
    
    func onClickLogout() {
        // show login dialog
        Twitter.sharedInstance().logOut()
        close(false)
        UIApplication.sharedApplication().keyWindow?.rootViewController = LoginViewController()
    }
    
    func close(reload: Bool) {
        var changed:Bool = reload
        // save all settings
        SettingStore.sharedInstance.saveHashtag(self.hashtagInput?.text)
        if let noConfirm = self.noConfirmSwitch {
            SettingStore.sharedInstance.saveNoConfirm(noConfirm.on)
        }
        if reload {
            self.onClose?()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onClickClose() {
        var reload:Bool = false
        if self.hashtagInput?.text != SettingStore.sharedInstance.getHashtag() {
            reload = true
        }
        if let noConfirm = self.noConfirmSwitch {
            if noConfirm.on != SettingStore.sharedInstance.isNoConfirm() {
                reload = true
            }
        }
        close(reload)
    }
}