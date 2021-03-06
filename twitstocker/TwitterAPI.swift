//
//  TwitterAPI.swift
//  twitstocker
//
//  Created by TEJIMA TAKUYA on 2014/12/24.
//  Copyright (c) 2014年 TEJIMA TAKUYA. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterAPI {
    let baseURL = "https://api.twitter.com"
    let version = "/1.1"
    
    init() {
    }
    
    class func getHomeTimeline(tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        self.callAPI("/statuses/home_timeline.json", parameters: nil, {
            response, data, err in
            if err == nil {
                var jsonError: NSError?
                let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                    options: nil,
                    error: &jsonError)
                if let jsonArray = json as? NSArray {
                    tweets(URLTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                }
            } else {
                error(err)
            }
        })
    }
    
    class func search(params: [NSObject : AnyObject]!, tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        self.callAPI("/search/tweets.json", parameters: params, {
            response, data, err in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            if err == nil {
                var jsonError: NSError?
                let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                    options: nil,
                    error: &jsonError)
                if let top = json as? NSDictionary {
                    var list: [TWTRTweet] = []
                    if let statuses = top["statuses"] as? NSArray {
                        list = URLTweet.tweetsWithJSONArray(statuses) as [TWTRTweet]
                    }
                    tweets(list)
                }else if let jsonArray = json as? NSArray {
                    tweets(URLTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                }
            } else {
                error(err)
            }
        })
    }
    
    class func listMyFavorites(params: [NSObject : AnyObject]!, tweets: [TWTRTweet]->(), error: (NSError) -> ()) {
        self.callAPI("/favorites/list.json", parameters: params, {
            response, data, err in
            if err == nil {
                var jsonError: NSError?
                let json: AnyObject? =  NSJSONSerialization.JSONObjectWithData(data,
                    options: nil,
                    error: &jsonError)
                if let jsonArray = json as? NSArray {
                    tweets(URLTweet.tweetsWithJSONArray(jsonArray) as [TWTRTweet])
                }
            } else {
                error(err)
            }
        })
    }
    
    class func favoriteTweet(params: [NSObject : AnyObject]!, success: ()->(), error: (NSError) -> ()) {
        self.callPostAPI("/favorites/create.json", parameters: params, {
            response, data, err in
            if err == nil {
                success()
            } else {
                error(err)
            }
        })
    }

    class func unfavoriteTweet(params: [NSObject : AnyObject]!, success: ()->(), error: (NSError) -> ()) {
        self.callPostAPI("/favorites/destroy.json", parameters: params, {
            response, data, err in
            if err == nil {
                success()
            } else {
                error(err)
            }
        })
    }
    
    class func deleteTweet(id: String, success: ()->(), error: (NSError) -> ()) {
        self.callPostAPI("/statuses/destroy/" + id + ".json", parameters: nil, {
            response, data, err in
            if err == nil {
                success()
            } else {
                error(err)
            }
        })
    }
    
    class func updateTweet(params: [NSObject : AnyObject]!, success: ()->(), error: (NSError) -> ()) {
        self.callPostAPI("/statuses/update.json", parameters: params, {
            response, data, err in
            if err == nil {
                success()
            } else {
                error(err)
            }
        })
    }
    
    class func callAPI(path: String, parameters: [NSObject : AnyObject]!, completion: TWTRNetworkCompletion!){
        self._callAPI(path, method: "GET", parameters: parameters, completion)
    }

    class func callPostAPI(path: String, parameters: [NSObject : AnyObject]!, completion: TWTRNetworkCompletion!){
        self._callAPI(path, method: "POST", parameters: parameters, completion)
    }

    class func _callAPI(path: String, method: String, parameters: [NSObject : AnyObject]!, completion: TWTRNetworkCompletion!){
        let api = TwitterAPI()
        var clientError: NSError?
        let endpoint = api.baseURL + api.version + path
        let request = Twitter.sharedInstance().APIClient.URLRequestWithMethod(method, URL: endpoint, parameters: parameters, error: &clientError)
        if request != nil {
            Twitter.sharedInstance().APIClient.sendTwitterRequest(request, completion: completion)
        }
    }
}