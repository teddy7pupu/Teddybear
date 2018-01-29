//
//  Approval.swift
//  teddybear
//
//  Created by msp310 on 2018/1/28.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation

struct Approval: Codable {
    var aid: String? //approval ID
    var time: Int? //簽核時間
    var leaveId: String? //leave ID
    var sid: String? //簽核者 ID
    var status: Int? // 簽核狀態 0:未簽核 / 1:通過 / 2:拒絕
    var message: [String]? // 簽核者回應
    
    init() {
    }
    
    init(approval: String) {
        self.aid = approval
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary) -> Approval? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Approval.self, from: json)
    }
}
