//
//  StaffManager.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class StaffManager: NSObject {
    
    private static var mInstance: StaffManager?
    private var dbRef: DatabaseReference?
    override private init() {
        super.init()
        self.dbRef = Database.database().reference()
    }
    
    // MARK: Public method
    static func sharedInstance() -> StaffManager {
        if mInstance == nil {
            mInstance = StaffManager()
        }
        return mInstance!
    }
    
    func createStaff(staff: Staff, completion:@escaping (Staff?, Error?) -> Void) {
        staffRef()?.childByAutoId().updateChildValues(staff.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(staff, nil)
        })
    }
    
    func getStaffList(completion:@escaping ([Staff]?, Error?) -> Void) {
        staffRef()?.observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Staff] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                let staff = Staff.get(data: data?.value as! NSDictionary)
                list.append(staff!)
            }
            completion(list, nil)
        })
    }
    
    // MARK: Getter
    private func staffRef() -> DatabaseReference? {
        return self.dbRef?.child(tbDefines.kStaff)
    }
}
