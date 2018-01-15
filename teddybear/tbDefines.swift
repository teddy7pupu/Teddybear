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
    
    // MARK: Color
    static let colorSUN = UIColor.init(red: 255/255, green: 147/255, blue: 0, alpha: 1)
    static let colorFBLUE = UIColor.init(red: 59/255, green: 89/255, blue: 136/255, alpha: 1)
}
