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
    
    static let intern   = UserRole(rawValue: 0)
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
    func isIntern() -> Bool {
        return self == .intern
    }
    func isAdmin() -> Bool {
        return self == .admin
    }
    mutating func setRole(_ isManager:Bool, _ isAccount:Bool, _ isIntern:Bool) {
        if isManager && isAccount {
            self = .admin
        } else if isManager {
            self = .manager
        } else if isAccount {
            self = .account
        } else if isIntern {
            self = .intern
        } else {
            self = .employee
        }
    }
    
    func functionList() -> [tbTabFunction] {
        var list: [tbTabFunction]
        switch self {
        case UserRole.admin:
            list = [.Leave, .Approval, .Report, .Me]
            break
        case UserRole.account:
            list = [.Leave, .Approval, .Report, .Me]
        case UserRole.manager:
            list = [.Leave, .Approval, .Me]
        case UserRole.intern:
            list = [.Attendance, .InterReport, .Me]
        default:
            list = [.Leave, .Approval, .Me]
        }
        return list
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
    var quitDate: Int?
    
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
