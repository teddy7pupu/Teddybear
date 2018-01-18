//
//  tbDefines.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import Firebase

class tbDefines: NSObject {
    static let BUNDLEID = Bundle.main.bundleIdentifier!
    static let FIRClientID = FirebaseApp.app()?.options.clientID
    static let AMDomain = "@appmaster.cc"
    
    // MARK: Key
    static let kStaff = "Staff"
    static let kDepartment = "Department"
    
    // MARK: Segue
    static let kSegueLobby = "SegueLobby"
    static let kSegueDetail = "SegueDetail"
}
