//
//  Staff.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/15.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation

struct UserRole: OptionSet, Codable {
    let rawValue: Int
    
    static let employee = UserRole(rawValue: 1 << 0)
    static let manager  = UserRole(rawValue: 1 << 1)
    static let account  = UserRole(rawValue: 1 << 2)
}

struct Staff: Codable {
    var uid: String?
    var name: String?
    var english: String?
    var title: String?
    var email: String?
    var mobile: String?
    var avatar: String?
    var birthday: Int?
    var onBoardDate: Int?
    var role: UserRole?
    var department: String?
    var sid: String?
    
    init() {
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary) -> Staff? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Staff.self, from: json)
    }
}
