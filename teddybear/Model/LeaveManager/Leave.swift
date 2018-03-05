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
    var type: LeaveType?    //假別
    var applyTime: Int?     //申請日期
    var startTime: Int?     //假單起始日
    var endTime: Int?       //假單結束日
    var message: String?    //請假原因
    var assigneeId: String? //代理人ID
    var approvals: [Approval]? //簽核清單
    var departmentId: String?//部門ID
    
    enum LeaveType: String, Codable, EnumCollection {
        case annual = "特休假"
        case personal = "事假"
        case sick = "病假"
        case marriage = "婚假"
        case funeral = "喪假"
        case maternity = "產假"
        case paternity = "陪產假"
    }
    
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
    
    func leaveStatus() -> Int { //0:待簽核, 1:核准: 2:拒絕
        guard let approvals = self.approvals else { return 0 }
        
        var status = 0
        switch approvals.count {
        case 1:
            status = approvals[0].status!
            break
        case 2:
            status = approvals[1].status!
        default: break
        }
        return status
    }
    
    static func get(data: NSDictionary) -> Leave? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Leave.self, from: json)
    }
}
