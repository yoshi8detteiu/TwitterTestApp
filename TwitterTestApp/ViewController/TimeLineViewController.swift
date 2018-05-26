//
//  ViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/25.
//  Copyright © 2018年 椎名陽介. All rights reserved.
//

import UIKit
import AlamofireImage

class TimeLineViewController: UIViewController {

    @IBOutlet weak var timelineTableView: LambdaTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ログインチェック
        let sessionStore = TWTRTwitter.sharedInstance().sessionStore
        if let session = sessionStore.session() {
            self.requestTimeLine(session.userID, {twArray in
                self.loadTimeLineTableView(twArray)
            })
            return
        }
        
        // 初回ログイン
        TWTRTwitter.sharedInstance().logIn {[weak self]  session, error in
            if let session = session {
                self?.requestTimeLine(session.userID, {twArray in
                    self?.loadTimeLineTableView(twArray)
                })
            }
            else if let error = error {
                // TODO: アラート
                print("error: \(error.localizedDescription)")
            }
        }
        
        
    }
    
    private func requestTimeLine(_ userId: String, _ afterAction:@escaping (Array<TWTRTweet>) -> Void ) {
        
        var clientError: NSError?
        
        let apiClient = TWTRAPIClient(userID: userId)
        let request = apiClient.urlRequest(withMethod: "GET",
                                           urlString: "https://api.twitter.com/1.1/statuses/home_timeline.json",
                                           parameters: ["user_id": userId,
                                                        "count": "50",], // Intで渡すとエラー
                                           error: &clientError)
        
        
        apiClient.sendTwitterRequest(request) {[weak self] response, data, error in
            if let error = error {
                // TODO: アラート
                print(error.localizedDescription)
            }
            else if let data = data, let tweetArray = self?.convertTweet(data) {
                afterAction(tweetArray)
            }
        }
    }
    
    private func convertTweet(_ data: Data) -> Array<TWTRTweet> {
        
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
    
    private func loadTimeLineTableView(_ twArray: Array<TWTRTweet>) {
        
        self.timelineTableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.timelineTableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        self.timelineTableView.estimatedRowHeight = 87
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        
        self.timelineTableView.dataSourceNumberOfRowsInSection = {section in
            return twArray.count
        }
        
        self.timelineTableView.dataSourceNumberOfSections = {
            return 1
        }
        
        
        self.timelineTableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension // 87 // TEMP
        }
        
        self.timelineTableView.dataSourceCellForRowAt = {[weak self] indexPath in
            let cell = self?.timelineTableView.dequeueReusableCell(withIdentifier: "TweetViewCell", for: indexPath) as! TweetViewCell
            
            let tweet = twArray[indexPath.row]
            cell.tweetLabel.text      = tweet.text
            cell.authorNameLabel.text = tweet.author.name
            cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.author.profileImageURL)!)
            
//            cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.author.profileImageURL)!, completion: {[weak self] res in
//                self?.timelineTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
//            })
//            cell.authorIconButton.af_setBackgroundImage(for: UIControlState.normal, url: URL(string: tweet.author.profileImageURL)!)
            cell.layoutIfNeeded()
            return cell
        }
        
        self.timelineTableView.reloadData()
        
        // reloadData後にTopへ移動
//        UIView.animate(withDuration: 0.0,
//                       animations:{
//                            self.timelineTableView.reloadData()
//                            self.timelineTableView.layoutIfNeeded()
//                        },
//                       completion:{[weak self] finished in
//                            if finished {
//                                self?.timelineTableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
//                            }
//                        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

