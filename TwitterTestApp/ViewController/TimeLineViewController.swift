//
//  ViewController.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/25.
//  Copyright © 2018年 椎名陽介. All rights reserved.
//

import UIKit
import TwitterKit

class TimeLineViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if session != nil {
                print("signed in as \(session!.userName)")
            }
            else {
                print("error: \(error!.localizedDescription)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

