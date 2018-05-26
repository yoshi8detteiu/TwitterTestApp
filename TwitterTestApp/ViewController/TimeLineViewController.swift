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
    
    private var model:TimeLineModel = TimeLineModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.model.loadTimeLine(
            {[weak self] twArray in
                self?.loadTimeLineTableView(twArray)
            },
            { message in
                //TODO: アラート
            })
    }
    
    private func loadTimeLineTableView(_ twArray: Array<TWTRTweet>) {
        
        self.timelineTableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.timelineTableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        self.timelineTableView.estimatedRowHeight = 78
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        
        self.timelineTableView.dataSourceNumberOfRowsInSection = {section in
            return twArray.count
        }
        
        self.timelineTableView.dataSourceNumberOfSections = {
            return 1
        }
        
        self.timelineTableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension
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
            cell.pushedIconButton = {[weak self] sender in
                // タップされたユーザのページへ
                let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
                let nextView  = storyboard.instantiateInitialViewController()
                self?.navigationController?.pushViewController(nextView!, animated: true)
            }
            cell.layoutIfNeeded()
            return cell
        }
        
        self.timelineTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

