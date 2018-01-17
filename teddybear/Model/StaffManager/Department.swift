//
//  Department.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

struct Department: Codable {
    var department_id: String?
    var title: String?
    var supervisor: String?
    var supervisor_id: String?
    
    init() {
    }
    
    func dictionaryData() -> [String: Any] {
        let encoder: JSONEncoder = JSONEncoder()
        let encoded = try? encoder.encode(self)
        return try! JSONSerialization.jsonObject(with: encoded!, options: .allowFragments) as! [String : Any]
    }
    
    static func get(data: NSDictionary) -> Department? {
        guard let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(Department.self, from: json)
    }
}
