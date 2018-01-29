//
//  Leave.swift
//  teddybear
//
//  Created by Teddy on 2018/1/23.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//
import Foundation

struct Leave: Codable {
    var leaveId: String?    //假單ID
    var sid: String?        //員工id
    var type: String?       //假別
    var applyTime: Int?     //申請日期
    var startTime: Int?     //假單起始日
    var startPeriod: Int?   //假單開始時段 0 -> 10:00 ; 1 -> 15:00
    var endTime: Int?       //假單結束日
    var endPeriod: Int?     //假單結束時段 0 -> 14:00 ; 1 -> 19:00
    var message: String?    //請假原因
    var assigneeId: String? //代理人ID
    var departmentId: String?//部門ID
    
    init() {
    }
    
    init(leaveId: String) {
        self.leaveId = leaveId
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary) -> Leave? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Leave.self, from: json)
    }
}
