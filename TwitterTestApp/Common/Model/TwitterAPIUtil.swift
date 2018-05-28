//
//  TwitterAPIUtil.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation
import SwiftyJSON

class TwitterAPIUtil: NSObject {
    
    static func requestHomeTimeLine(_ sessionUserId:String, _ maxId: String = "", _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        
        var clientError: NSError?
        let apiClient = TWTRAPIClient(userID: sessionUserId)
        var request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/home_timeline.json",
                                           parameters: ["count": "30"],
                                           error: &clientError)
        
        if !maxId.isEmpty {
            request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/home_timeline.json",
                                           parameters: ["count": "30",
                                                        "max_id": maxId],
                                           error: &clientError)
        }

        apiClient.sendTwitterRequest(request) { response, data, error in
            if let error = error {
                print(error.localizedDescription)
                errorAction("リクエストに失敗しました。リクエスト上限に達した可能性があります。")
            }
            else if let data = data {
                let tmArray = TwitterAPIUtil.convertTweetModel(data)
                afterAction(tmArray)
            }
        }
    }
    
    static func requestUserTimeLine(_ sessionUserId:String, _ userId:String, _ maxId:String = "", _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        var clientError: NSError?
        
        let apiClient = TWTRAPIClient(userID: sessionUserId)
        var request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json",
                                           parameters: ["user_id": userId,
                                                        "count": "30"],
                                           error: &clientError)
        
        if !maxId.isEmpty {
            request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json",
                                           parameters: ["user_id": userId,
                                                        "count": "30",
                                                        "max_id": maxId ],
                                           error: &clientError)
        }
        
        
        apiClient.sendTwitterRequest(request) { response, data, error in
            if let error = error {
                print(error.localizedDescription)
                errorAction("リクエストに失敗しました。リクエスト上限に達した可能性があります。")
            }
            else if let data = data {
                let tmArray = TwitterAPIUtil.convertTweetModel(data)
                afterAction(tmArray)
            }
        }
    }
    
    static func requestSearch(_ sessionUserId: String, _ searchText: String, _ maxId:String = "", _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        var clientError: NSError?
        
        let apiClient = TWTRAPIClient(userID: sessionUserId)
        var request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/search/tweets.json",
                                           parameters: ["q": searchText,
                                                        "count": "30"],
                                           error: &clientError)
        
        if !maxId.isEmpty {
            request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/search/tweets.json",
                                           parameters: ["q": searchText,
                                                        "count": "30",
                                                        "max_id": maxId ],
                                           error: &clientError)
        }
        
        apiClient.sendTwitterRequest(request) { response, data, error in
            if let error = error {
                print(error.localizedDescription)
                errorAction("リクエストに失敗しました。リクエスト上限に達した可能性があります。")
            }
            else if let data = data {
                let tmArray = TwitterAPIUtil.convertSearchTweetModel(data)
                afterAction(tmArray)
            }
        }
    }
    
    private static func convertTweet(_ data: Data) -> Array<TWTRTweet> {
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! Array<Any>
            let twArray = TWTRTweet.tweets(withJSONArray: jsonArray) as! [TWTRTweet]
            return twArray
        }
        catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
        return Array<TWTRTweet>()
    }
    
    /**
     * TWTRTweetだと情報が足りないので、SwiftyJsonで不足情報を取得・付与したTweetModelを使う
     */
    private static func convertTweetModel(_ data: Data) -> Array<TweetModel> {
        
        do {
            let jsonArray = try JSON(data: data).array
            let twArray = TwitterAPIUtil.convertTweet(data)
            return TwitterAPIUtil.convertTWTRTweetArrayToWeetModelArray(twArray, jsonArray!)
        }
        catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
        return Array<TweetModel>()
        
    }
    
    private static func convertTWTRTweetArrayToWeetModelArray(_ twArray: Array<TWTRTweet>, _ jsonArray: [JSON] ) -> Array<TweetModel> {
        
        var tmArray = Array<TweetModel>()
        
        for (index, value) in twArray.enumerated() {
            let model = TweetModel()
            model.base = value
            model.authorModel.base = value.author
            
            let twJson = jsonArray[index]
            let autJson = twJson["user"]
            model.authorModel.linkUrl = URL(string:(autJson["url"].stringValue))
            model.authorModel.profileText = autJson["description"].stringValue
            model.authorModel.followCount = autJson["friends_count"].intValue
            model.authorModel.followerCount = autJson["followers_count"].intValue
            model.authorModel.backgroundImagePath = autJson["profile_background_image_url"].stringValue
            
            tmArray.append(model)
        }
        return tmArray
    }
    
    private static func convertSearchTweetModel(_ data:Data) -> Array<TweetModel> {
    
        do {
            let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            let array = dic?["statuses"] as! Array<Any>
            let twArray = TWTRTweet.tweets(withJSONArray: array) as! [TWTRTweet]
            
            let json = try JSON(data: data)
            let jsonArray = json["statuses"].array!
            
            return TwitterAPIUtil.convertTWTRTweetArrayToWeetModelArray(twArray, jsonArray)
        }
        catch let jsonError as NSError {
            print("json error: \(jsonError.localizedDescription)")
        }
        return Array<TweetModel>()
    
    }
    
}
