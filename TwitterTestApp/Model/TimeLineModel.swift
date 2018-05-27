//
//  TimeLineModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class TimeLineModel: NSObject {
    
    private var isLoading = false
    
    func loadTimeLine(_ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
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
            TwitterAPIUtil.requestHomeTimeLine(session.userID, "", afterTask, errorTask)
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn { session, error in
            if let session = session {
                self.isLoading = true
                TwitterAPIUtil.requestHomeTimeLine(session.userID, "", afterTask, errorTask)
            }
            else if let error = error {
                print("error: \(error.localizedDescription)")
                errorAction("ログインに失敗しました")
            }
        }
    }
    
    func logout() {
 
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        
        // アクティブなアカウントのsessionを取得
        if let session = sessionStore.session() {
            // userIDでログアウト
            sessionStore.logOutUserID(session.userID)
        }
    }
    
    func isLogin() -> Bool {
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        return sessionStore.session() != nil
    }
    
    func moreTimeLine(_ maxId:String, _ afterAction:@escaping (Array<TweetModel>) -> Void, _ errorAction:@escaping (String) -> Void) {
        
        if self.isLoading { return }
        
        let afterTask:((Array<TweetModel>) -> Void) = { [weak self] twArray in
            self?.isLoading = false
            afterAction(twArray)
        }
        
        let errorTask:((String) -> Void) = { [weak self] message in
            self?.isLoading = false
            errorAction(message)
        }
        
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.isLoading = true
            TwitterAPIUtil.requestHomeTimeLine(session.userID, maxId, afterTask, errorTask)
        }
        else {
            errorAction("再ログインしてください")
        }
    }
}
