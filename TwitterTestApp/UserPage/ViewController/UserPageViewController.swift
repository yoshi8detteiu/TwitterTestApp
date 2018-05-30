//
//  UserPageViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/26.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import UIKit

class UserPageViewController: UIViewController {

    /** Argument */
    var user:UserModel!
    /** VIew */
    @IBOutlet weak var tableView: LambdaTableView!
    @IBOutlet weak var tweetButton: UIButton!
    /** Model */
    private var model:UserPageModel = UserPageModel()
    private enum Section: Int {
        case user  = 0
        case tweet = 1
    }
    
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
        
        // Tweetボタンの出現
        self.tweetButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                            self?.tweetButton.transform = CGAffineTransform.identity
                        },
                       completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushTweetButton(_ sender: Any) {
        let composer = TWTRComposer()
        composer.show(from:self, completion: {[weak self] result in
            if result == TWTRComposerResult.done {
                self?.loadUserPageView()
            }
        })
    }

    /** RefreshControl event */
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        self.loadUserPageView()
        // ローディングを終了
        sender.endRefreshing()
    }
    
    /** Load view */
    private func loadUserPageView() {
        self.model.loadUserTimeLine(self.user.base!.userID,
                                    {[weak self] twArray in
                                        self?.loadTableView(twArray)
                                        },
                                     {[weak self] message in
                                        self?.showAlert(message)
                                    })
    }
    private func loadTableView(_ twArray: Array<TweetModel>) {
        
        self.tableView.register(UserViewCell.self, forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(UINib(nibName: "UserViewCell", bundle: nil), forCellReuseIdentifier: "UserViewCell")
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        
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
        self.tableView.delegateEstimatedHeightForRowAt = { indexPath in
            return 100
        }
        self.tableView.delegateEditingStyleForRowAt = { indexPath in
            return UITableViewCellEditingStyle.none
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
        
        self.tableView.delegateScrollDidScroll = { [weak self] in
            
            let currentOffsetY = (self?.tableView.contentOffset.y)!
            let maximumOffset = (self?.tableView.contentSize.height)! - (self?.tableView.frame.height)!
            let distanceToBottom = maximumOffset - currentOffsetY
            if distanceToBottom < 300 {
                // 無限スクロール
                self?.moreTimeLineView(twArray)
            }
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
        
        cell.userImageView.af_setImage(withURL: URL(string: self.user.base!.profileImageLargeURL)!,
                                       placeholderImage: UIImage(named: "placeholder_oval"),
                                       imageTransition: UIImageView.ImageTransition.crossDissolve(0.1))
        
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
        
        cell.authorIconImageView.af_setImage(withURL: URL(string: tweet.authorModel.base!.profileImageURL)!,
                                             placeholderImage: UIImage(named: "placeholder_oval"),
                                             imageTransition: UIImageView.ImageTransition.crossDissolve(0.1))
        cell.pushedIconButton = {[weak self] sender in
            self?.presentUserPage(tweet)
        }
        cell.layoutIfNeeded()
        return cell
    }
    private func moreTimeLineView(_ oldTwArray: Array<TweetModel>) {
        
        if oldTwArray.count == 0 { return}
        
        let maxId = oldTwArray.last?.base?.tweetID
        self.model.moreTimeLine(self.user.base!.userID,
                                maxId!,
                                {[weak self] twArray in
                                    let newTwArray = oldTwArray + twArray
                                    // reloadDataでoffsetがリセットされないように
                                    let offset = self?.tableView.contentOffset
                                    self?.loadTableView(newTwArray)
                                    self?.tableView.layoutIfNeeded()
                                    self?.tableView.contentOffset = offset!
                                },
                                {[weak self] message in
                                    self?.showAlert(message)
                                })
    }
    
    private func showAlert(_ message:String) {
        let alert = UIAlertController(title: "エラーです", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let close = UIAlertAction(title: "閉じる", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        alert.addAction(close)
        self.present(alert, animated: true, completion: nil)
    }
    private func presentUserPage(_ tweet:TweetModel) {
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                            self?.tweetButton.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        },
                       completion: {  [weak self] result in
                            // タップされたユーザのページへ
                            let storyboard: UIStoryboard = UIStoryboard(name: "UserPageViewController", bundle: nil)
                            let nextView  = storyboard.instantiateInitialViewController() as! UserPageViewController
                            nextView.user = tweet.authorModel
                            self?.navigationController?.pushViewController(nextView, animated: true)
                        })
    }

}
