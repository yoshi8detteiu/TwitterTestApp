//
//  UserPageModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class UserPageModel: NSObject {
    
    private var isLoading = false
    private var noMore = false
    
    func loadUserTimeLine(_ userId:String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        if self.isLoading { return }
        
        let afterTask:((Array<TweetModel>) -> Void) = { [weak self] twArray in
            afterAction(twArray)
            self?.isLoading = false
        }
        
        let errorTask:((String) -> Void) = { [weak self] message in
            errorAction(message)
            self?.isLoading = false
        }
        
        // ログインチェック
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.isLoading = true
            TwitterAPIUtil.requestUserTimeLine(session.userID, userId, "", afterTask, errorTask)
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                self.isLoading = true
                TwitterAPIUtil.requestUserTimeLine(session.userID, userId, "", afterTask, errorTask)
            }
            else if let error = error {
                print("error: \(error.localizedDescription)")
                errorAction("ログインに失敗しました")
            }
        }
    }
    
    
    func moreTimeLine(_ userId:String, _ maxId:String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        if self.isLoading || self.noMore { return }
        
        let afterTask:((Array<TweetModel>) -> Void) = { [weak self] twArray in
            self?.isLoading = false
            // maxIdのtweetも混ざるので削除
            var twArray = twArray
            twArray.remove(at: 0)
            if twArray.count > 0  {
                afterAction(twArray)
            }
            else {
                // 古いツイートはないので打止
                // MEMO: 投稿や更新後にfalseにすべき
                self?.noMore = true
            }
        }
        
        let errorTask:((String) -> Void) = { [weak self] message in
            self?.isLoading = false
            errorAction(message)
        }
        
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.isLoading = true
            TwitterAPIUtil.requestUserTimeLine(session.userID, userId, maxId, afterTask, errorTask)
        }
        else {
            errorAction("再ログインしてください")
        }
    }
    
}
