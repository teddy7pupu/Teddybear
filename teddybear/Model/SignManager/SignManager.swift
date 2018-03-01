//
//  SignManager.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class SignManager: NSObject{
    
    private static var mInstance: SignManager?
    private var dbRef: DatabaseReference?
    private var mSignList: [Sign]?
    
    override private init() {
        super.init()
        dbRef = Database.database().reference()
    }
    
    //MARK: Public method
    static func sharedInstance() -> SignManager {
        if mInstance == nil {
            mInstance = SignManager()
        }
        return mInstance!
    }
    
    func getAutoKey() -> String? {
        guard let autoKey = signRef()?.childByAutoId().key else { return nil }
        return autoKey
    }
    
    func updateSignData(_ sign: Sign!,completion:@escaping (Sign?, Error?) -> Void) {
        signRef()?.child(sign.signId!).updateChildValues(sign.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(sign, nil)
        })
    }
    
    func getRangeSignList(_ start: Int, _ end: Int, completion:@escaping ([Sign]?, Error?) -> Void) {
        queryRangeSignList(key:"startTime", start: start, end: end, completion: completion)
    }
    
    private func queryRangeSignList(key: String!, start: Int, end: Int, completion:@escaping ([Sign]?, Error?) -> Void) {
        signRef()?.queryOrdered(byChild: key).queryStarting(atValue: start).queryEnding(atValue: end).observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Sign] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let sign = Sign.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "資料錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(sign)
            }
            completion(list.sorted(by: { TimeInterval($0.startTime!) > TimeInterval($1.startTime!) }), nil)
        })
    }
    
    func getSignList(_ sid:String!, completion:@escaping ([Sign]?, Error?) -> Void) {
        querySignList(key:"sid", value: sid, completion: completion)
    }
    
    private func querySignList(key: String!, value:Any, completion:@escaping ([Sign]?, Error?) -> Void) {
        signRef()?.queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Sign] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let sign = Sign.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "資料錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(sign)
            }
            self.mSignList = list.sorted(by: { TimeInterval($0.startTime!) > TimeInterval($1.startTime!) })
            completion(self.mSignList, nil)
        })
    }
    
    //MARK: Private Getter
    func signRef () -> DatabaseReference? {
        return dbRef?.child(tbDefines.kSign)
    }
}
