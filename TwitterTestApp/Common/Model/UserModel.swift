//
//  UserModel.swift
//  TwitterTestApp
//
//  Created by 椎名陽介 on 2018/05/27.
//  Copyright © 2018 椎名陽介. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    var base:TWTRUser?
    var linkUrl:URL?
    var profileText:String?
    var followCount:Int?
    var followerCount:Int?
    var backgroundImagePath:String?
}
