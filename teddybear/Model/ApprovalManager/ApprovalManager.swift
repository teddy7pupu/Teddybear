//
//  ApprovalManager.swift
//  teddybear
//
//  Created by msp310 on 2018/1/28.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class ApprovalManager: NSObject{
    
    private static var mInstance: ApprovalManager?
    private var dbRef: DatabaseReference?
    private var mApprovalList: [Approval]?
    
    override private init() {
        super.init()
        dbRef = Database.database().reference()
    }
    
    //MARK: Public method
    static func sharedInstance() -> ApprovalManager {
        if mInstance == nil {
            mInstance = ApprovalManager()
        }
        return mInstance!
    }
    
    func getAutoKey() -> String? {
        guard let autoKey = approvalRef()?.childByAutoId().key else { return nil }
        return autoKey
    }
    
    func updateApprovalData(_ approval: Approval!,completion:@escaping (Approval?, Error?) -> Void) {
        
        approvalRef()?.child(approval.aid!).updateChildValues(approval.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(approval, nil)
        })
    }
    
    func getApprovalList(_ sid:String!, completion:@escaping ([Approval]?, Error?) -> Void) {
        queryApprovalList(key:"sid", value: sid, completion: completion)
    }
    
    private func queryApprovalList(key: String!, value:Any, completion:@escaping ([Approval]?, Error?) -> Void) {
        approvalRef()?.queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Approval] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let approval = Approval.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "假單資料錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(approval)
            }
            self.mApprovalList = list
            completion(list, nil)
        })
    }
    
    //MARK: Private Getter
    func approvalRef () -> DatabaseReference? {
        return dbRef?.child(tbDefines.kApproval)
    }
}
