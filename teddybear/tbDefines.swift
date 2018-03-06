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
    static let kWifi = "Wifi"

    
    // MARK: Segue
    static let kSegueLogin = "SegueLogin"
    static let kSegueLobby = "SegueLobby"
    static let kSegueDetail = "SegueDetail"
    static let kSegueApproval = "SegueApproval"
    static let kSegueReport = "SegueReport"
    static let kSegueLeaveManager = "SegueLeaveManager"
    static let kSegueApprovalManager = "SegueApprovalManager"
}
