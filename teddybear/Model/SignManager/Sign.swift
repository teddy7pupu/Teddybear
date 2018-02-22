//
//  Sign.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation

struct Sign: Codable {
    var startTime: Int? //簽到時間
    var endTime: Int?   //簽退時間
    var signId: String? //簽到單 ID
    var sid: String?    //簽到人 ID
    
    init() {
    }
    
    init(signId: String) {
        self.signId = signId
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary) -> Sign? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Sign.self, from: json)
    }
}
