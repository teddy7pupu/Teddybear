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
    
    func removeLeaveData(_ leave: Leave!, completion:@escaping (Error?) -> Void) {
        leaveRef()?.child(leave.leaveId!).removeValue(completionBlock: { (error, reference) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        })
    }
    
    func getRangeLeaveList(_ start: Int, _ end: Int, completion:@escaping ([Leave]?, Error?) -> Void) {
        queryRangeLeaveList(key:"applyTime", start: start, end: end, completion: completion)
    }
    
    private func queryRangeLeaveList(key: String!, start: Int, end: Int, completion:@escaping ([Leave]?, Error?) -> Void) {
        leaveRef()?.queryOrdered(byChild: key).queryStarting(atValue: start).queryEnding(atValue: end).observeSingleEvent(of: .value, with: { SnapShot in
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
            completion(list, nil)
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
            self.mLeaveList = list.sorted(by: { TimeInterval($0.applyTime!) < TimeInterval($1.applyTime!) })
            completion(list, nil)
        })
    }
    
    func getLeave(_ leaveId: String!, completion:@escaping (Leave?, Error?) -> Void) {
        queryLeave(key: "leaveId", value: leaveId, completion: completion)
    }
    
    private func queryLeave(key: String!, value:Any, completion:@escaping (Leave?, Error?) -> Void) {
        leaveRef()?.queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { SnapShot in
            var result: Leave?
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let leave = Leave.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "假單資料錯誤"])
                    completion(nil, error)
                    return
                }
                result = leave
                break
            }
            completion(result, nil)
        })
    }
    
    //MARK: Private Getter
    func leaveRef () -> DatabaseReference? {
        return dbRef?.child(tbDefines.kLeave)
    }
}
