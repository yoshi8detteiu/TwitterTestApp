//
//  UserPageViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit

class UserPageViewController: UIViewController {

    var user:TWTRUser!
    
    @IBOutlet weak var tableView: LambdaTableView!
    
    private var model:UserPageModel = UserPageModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.model.loadUserTimeLine(self.user.userID,
            {[weak self] twArray in
                self?.loadTableView(twArray)
            },
            { message in
                //TODO: アラート
            })
    }
    
    private enum Section: Int {
        case user  = 0
        case tweet = 1
        
    }
    
    private func loadTableView(_ twArray: Array<TWTRTweet>) {
        
        self.tableView.register(UserViewCell.self, forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        self.tableView.estimatedRowHeight = 78
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.dataSourceNumberOfRowsInSection = {section in
            if section == Section.user.rawValue {
                return 1
            }
            else if section == Section.tweet.rawValue {
                return twArray.count
            }
            return 0
        }
        
        self.tableView.dataSourceNumberOfSections = {
            return 2
        }
        
        self.tableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension
        }
        
        self.tableView.dataSourceCellForRowAt = {[weak self] indexPath in
            
            if indexPath.section == Section.user.rawValue {
                let userCell = self?.loadUserCell(indexPath)
                return userCell!
            }
            else if indexPath.section == Section.tweet.rawValue {
                let tweetCell = self?.loadTweetCell(indexPath,twArray)
                return tweetCell!
            }
            return UITableViewCell()
        }
        
        self.tableView.reloadData()
    }
    
    private func loadUserCell(_ indexPath:IndexPath) -> UserViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "UserViewCell", for: indexPath) as! UserViewCell
        
        cell.userImageView.af_setImage(withURL: URL(string: self.user.profileImageURL)!)
        cell.nameLabel.text = self.user.name
        cell.screenNameLabel.text = "@" + self.user.screenName
        cell.bioLabel.text = self.user.description
        
        do {
            let urlStr = try String(contentsOf: self.user.profileURL)
            if urlStr.isEmpty {
                cell.linkView.isHidden = true
            }
            else {
                cell.linkView.isHidden = false
                cell.linkButton.titleLabel?.text = urlStr
                cell.pushedLinkButton = { sender in
                    // リンクをSafariで開く
                    if UIApplication.shared.canOpenURL(self.user.profileURL) {
                        UIApplication.shared.open(self.user.profileURL)
                    }
                }
            }
        }
        catch let error as NSError {
            cell.linkView.isHidden = true
            print("url -> string error: \(error.localizedDescription)")
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    private func loadTweetCell(_ indexPath:IndexPath, _ twArray: Array<TWTRTweet>) -> TweetViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TweetViewCell", for: indexPath) as! TweetViewCell
        
        let tweet = twArray[indexPath.row]
        cell.tweetLabel.text      = tweet.text
        cell.authorNameLabel.text = tweet.author.name
        cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.author.profileImageURL)!)
        cell.pushedIconButton = {[weak self] sender in
            // タップされたユーザのページへ
            let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
            let nextView  = storyboard.instantiateInitialViewController() as! UserPageViewController
            nextView.user = tweet.author
            self?.navigationController?.pushViewController(nextView, animated: true)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
