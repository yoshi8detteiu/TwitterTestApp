//
//  UserPageViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit

class UserPageViewController: UIViewController {

    var user:UserModel!
    
    @IBOutlet weak var tableView: LambdaTableView!
    
    private var model:UserPageModel = UserPageModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = self.user.base?.name
        //空白行のラインを消す
        self.tableView.tableFooterView = UIView()
        // RefreshControlのセット
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(hex: 0x1DA1F2)
        refreshControl.addTarget(self, action: #selector(TimeLineViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.loadUserPageView()
    }

    private func loadUserPageView() {
        self.model.loadUserTimeLine(self.user.base!.userID,
                                    {[weak self] twArray in
                                        self?.loadTableView(twArray)
                                        },
                                     {[weak self] message in
                                        self?.showAlert(message)
                                    })
    }
    
    private enum Section: Int {
        case user  = 0
        case tweet = 1
    }

    private func loadTableView(_ twArray: Array<TweetModel>) {
        
        self.tableView.register(UserViewCell.self, forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
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
        
//        if self.user.backgroundImagePath!.isEmpty {
//            cell.backgroundImageView.isHidden = true
//        }
//        else {
//            cell.backgroundImageView.isHidden = false
//            let url = URL(string: self.user.backgroundImagePath!)!
//            cell.backgroundImageView.af_setImage(withURL: url)
//        }
        
        cell.userImageView.af_setImage(withURL: URL(string: self.user.base!.profileImageLargeURL)!)
        cell.nameLabel.text = self.user.base?.name
        cell.screenNameLabel.text = "@" + self.user.base!.screenName
        cell.bioLabel.text = self.user.profileText
        cell.followCountLabel.text = String(self.user.followCount!)
        cell.followerCountLabel.text = String(self.user.followerCount!)
        
        let urlStr = self.user.linkUrl!.absoluteString
        if urlStr.isEmpty {
            cell.linkView.isHidden = true
        }
        else {
            cell.linkView.isHidden = false
            cell.linkButton.setTitle(urlStr, for: .normal)
            cell.pushedLinkButton = { sender in
                // リンクをSafariで開く
                if UIApplication.shared.canOpenURL(self.user.linkUrl!) {
                    UIApplication.shared.open(self.user.linkUrl!)
                }
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    private func loadTweetCell(_ indexPath:IndexPath, _ twArray: Array<TweetModel>) -> TweetViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TweetViewCell", for: indexPath) as! TweetViewCell
        
        let tweet = twArray[indexPath.row]
        cell.tweetLabel.text      = tweet.base?.text
        cell.authorNameLabel.text = tweet.base?.author.name
        cell.screenNameLabel.text = "@" + tweet.authorModel.base!.screenName
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d日 H:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        cell.dateLabel.text = formatter.string(from: tweet.base!.createdAt)
        
        cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.authorModel.base!.profileImageURL)!)
        cell.pushedIconButton = {[weak self] sender in
            // タップされたユーザのページへ
            let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
            let nextView  = storyboard.instantiateInitialViewController() as! UserPageViewController
            nextView.user = tweet.authorModel
            self?.navigationController?.pushViewController(nextView, animated: true)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        self.loadUserPageView()
        // ローディングを終了
        sender.endRefreshing()
    }
    
    private func showAlert(_ message:String) {
        let alert = UIAlertController(title: "エラーです", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let close = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
