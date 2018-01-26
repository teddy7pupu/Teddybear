//
//  LeaveManager.swift
//  teddybear
//
//  Created by Teddy on 2018/1/23.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class LeaveManager: NSObject{
    
    private static var mInstance: LeaveManager?
    private var dbRef: DatabaseReference?
    private var mLeaveList: [Leave]?
    
    override private init() {
        super.init()
        dbRef = Database.database().reference()
    }
    
    //MARK: Public method
    static func sharedInstance() -> LeaveManager {
        if mInstance == nil {
            mInstance = LeaveManager()
        }
        return mInstance!
    }
    
    func getAutoKey() -> String? {
        guard let autoKey = leaveRef()?.childByAutoId().key else { return nil }
        return autoKey
    }
    
    func updateLeaveData(_ leave: Leave!,completion:@escaping (Leave?, Error?) -> Void) {
        
        leaveRef()?.child(leave.leaveId!).updateChildValues(leave.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(leave, nil)
        })
    }
    
    func getLeaveList(_ sid:String!, completion:@escaping ([Leave]?, Error?) -> Void) {
        queryLeaveList(key:"sid", value: sid, completion: completion)
    }
    
    private func queryLeaveList(key: String!, value:Any, completion:@escaping ([Leave]?, Error?) -> Void) {
        leaveRef()?.queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Leave] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let leave = Leave.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "假單資料錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(leave)
            }
            self.mLeaveList = list
            completion(list, nil)
        })
    }
    
    //MARK: Private Getter
    func leaveRef () -> DatabaseReference? {
        return dbRef?.child(tbDefines.kLeave)
    }
}
