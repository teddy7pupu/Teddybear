//
//  WifiManager.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/22.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import SystemConfiguration.CaptiveNetwork

class WifiManager: NSObject{
    
    private static var mInstance: WifiManager?
    private var dbRef: DatabaseReference?
    
    override private init() {
        super.init()
        dbRef = Database.database().reference()
    }
    //MARK: Public method
    static func sharedInstance() -> WifiManager {
        if mInstance == nil {
            mInstance = WifiManager()
        }
        return mInstance!
    }
    
    func updateWifiData(_ wifi: Wifi!,completion:@escaping (Wifi?, Error?) -> Void) {
        wifiRef()?.updateChildValues(wifi.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(wifi, nil)
        })
    }
    
    func getWifiList(completion:@escaping (Wifi?, Error?) -> Void) {
        wifiList(key:"mac", completion: completion)
    }
    
    private func wifiList(key: String!, completion:@escaping (Wifi?, Error?) -> Void) {
        wifiRef()?.queryOrdered(byChild: key).observeSingleEvent(of: .value, with: { SnapShot in
            let data = SnapShot
            guard let wifi = Wifi.get(data: data.value as? NSDictionary) else {
                let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "資料錯誤"])
                completion(nil, error)
                return
            }
            completion(wifi, nil)
        })
    }
    
    func getCurrentWifi() -> (success: Bool, ssid: String?, mac: String?) {
        if let cfa: NSArray = CNCopySupportedInterfaces() {
            for x in cfa {
                if let dict = CFBridgingRetain(CNCopyCurrentNetworkInfo(x as! CFString)) {
                    let ssid = dict["SSID"]!
                    let mac  = dict["BSSID"]!
                    return (true, ssid as? String, mac as? String)
                }
            }
        }
        return (false,nil,nil)
    }
    
    //MARK: Private Getter
    func wifiRef () -> DatabaseReference? {
        return dbRef?.child(tbDefines.kWifi)
    }
}
