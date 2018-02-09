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
    static let kLeave = "Leave"
    static let kApproval = "Approval"
    static let kSign = "Sign"

    
    // MARK: Segue
    static let kSegueLobby = "SegueLobby"
    static let kSegueDetail = "SegueDetail"
    static let kSegueApproval = "SegueApproval"
    
    // MARK: Config
    static let kBeginSection = ["10:00", "15:00"]
    static let kEndSection = ["14:00", "19:00"]
    static let kLeaveType = ["特休假", "事假", "病假", "婚假", "喪假", "產假", "育嬰假"]
}
