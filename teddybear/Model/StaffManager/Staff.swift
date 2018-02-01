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
    
    static let employee = UserRole(rawValue: 1)
    static let manager  = UserRole(rawValue: 2)
    static let account  = UserRole(rawValue: 3)
    static let admin    = UserRole(rawValue: 4)
    
    func isManager() -> Bool {
        return (self == .manager) || (self == .admin)
    }
    func isAccount() -> Bool {
        return (self == .account) || (self == .admin)
    }
    func isAdmin() -> Bool {
        return self == .admin
    }
    mutating func setRole(_ isManager:Bool, _ isAccount:Bool) {
        if isManager && isAccount {
            self = .admin
        } else if isManager {
            self = .manager
        } else if isAccount {
            self = .account
        } else {
            self = .employee
        }
    }
    
    func functionList() -> Int {
        var count: Int
        switch self {
        case UserRole.admin:
            count = 4
            break
        case UserRole.account:
            count = 4
        case UserRole.manager:
            count = 3
        default:
            count = 2
        }
        return count
    }
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
    var isQuit: Bool?
    
    init() {
        role = .employee
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
