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

    @IBOutlet weak var tableView: LambdaTableView!
    
    private var model:TimeLineModel = TimeLineModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadTimeLineView()
    }
    
    private func loadTimeLineView() {
        self.model.loadTimeLine(
            {[weak self] twArray in
                self?.loadTableView(twArray)
            },
            { message in
                //TODO: アラート
        })
    }
    
    private func loadTableView(_ twArray: Array<TweetModel>) {
        
        self.tableView.register(TweetViewCell.self, forCellReuseIdentifier: "TweetViewCell")
        self.tableView.register(UINib(nibName: "TweetViewCell", bundle: nil), forCellReuseIdentifier: "TweetViewCell")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.dataSourceNumberOfRowsInSection = {section in
            return twArray.count
        }
        
        self.tableView.dataSourceNumberOfSections = {
            return 1
        }
        
        self.tableView.delegateHeightRowAt = { indexPath in
            return  UITableViewAutomaticDimension
        }
        
        self.tableView.dataSourceCellForRowAt = {[weak self] indexPath in
            let cell = self?.tableView.dequeueReusableCell(withIdentifier: "TweetViewCell", for: indexPath) as! TweetViewCell
            
            let tweet = twArray[indexPath.row]
            cell.tweetLabel.text      = tweet.base?.text
            cell.authorNameLabel.text = tweet.authorModel.base!.name
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
        
        self.tableView.reloadData()
    }
    
    @IBAction func pushMoreButton(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let search = UIAlertAction(title: "画像から検索", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            let storyboard: UIStoryboard = UIStoryboard(name: "SearchViewController", bundle: nil)
            let nextView  = storyboard.instantiateInitialViewController() as! SearchViewController
            self?.navigationController?.pushViewController(nextView, animated: true)
        })
        
        let logout = UIAlertAction(title: "ログアウト", style: UIAlertActionStyle.destructive, handler: {[weak self] (action: UIAlertAction!) in
            self?.model.logout()
            // ログアウト後に再ログイン
            self?.loadTimeLineView()
        })
        
        let login = UIAlertAction(title: "ログイン", style: UIAlertActionStyle.default, handler: {[weak self] (action: UIAlertAction!) in
            self?.loadTimeLineView()
        })
        
        let cancel = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel, handler: { (action: UIAlertAction!) in
            
        })
        
        
        actionSheet.addAction(search)
        if (self.model.isLogin()) {
            actionSheet.addAction(logout)
        }
        else {
            actionSheet.addAction(login)
        }
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

