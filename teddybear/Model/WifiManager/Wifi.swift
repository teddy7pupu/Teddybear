//
//  Wifi.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/22.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation

struct Wifi: Codable {
    var mac: [String]? //wifi名稱
    
    init() {
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary?) -> Wifi? {
        if data != nil {
            guard let json = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted) else { return nil }
            let decoder = JSONDecoder()
            return try? decoder.decode(Wifi.self, from: json)
        }
        return nil
    }
}
