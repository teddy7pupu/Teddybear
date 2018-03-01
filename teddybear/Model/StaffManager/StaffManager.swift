//
//  StaffManager.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class StaffManager: NSObject {
    
    private static var mInstance: StaffManager?
    private var dbRef: DatabaseReference?
    private var mStaffList: [Staff]?
    private var mDeptList: [Department]?
    
    var currentStaff: Staff?
    
    override private init() {
        super.init()
        self.dbRef = Database.database().reference()
    }
    
    // MARK: Public method
    static func sharedInstance() -> StaffManager {
        if mInstance == nil {
            mInstance = StaffManager()
        }
        return mInstance!
    }
    
    func updateStaff(_ staff: Staff!, completion:@escaping (Staff?, Error?) -> Void) {
        staffRef()?.child(staff.sid!).updateChildValues(staff.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            self.currentStaff = staff
            completion(staff, nil)
        })
    }
    
    func getStaffList(completion:@escaping ([Staff]?, Error?) -> Void) {
        staffRef()?.observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Staff] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let staff = Staff.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "員工資料格式錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(staff)
            }
            self.mStaffList = list
            completion(list, nil)
        })
    }
    
    func queryStaff(_ mail:String!, completion:@escaping (Staff?, Error?) -> Void) {
        self.queryStaff(key: "email", value: mail, completion: completion)
    }
    
    private func queryStaff(key:String!, value:Any, completion:@escaping (Staff?, Error?) -> Void) {
        staffRef()?.queryOrdered(byChild: key).queryEqual(toValue: value).observeSingleEvent(of: .value, with: { SnapShot in
            guard SnapShot.childrenCount != 0 else {
                let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "無此員工資料"])
                completion(nil, error)
                return
            }
            
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let staff = Staff.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "員工資料格式錯誤"])
                    completion(nil, error)
                    return
                }
                completion(staff, nil)
                break
            }
        })
    }
    
    func updateDepartment(_ department: Department!, completion:@escaping (Department?, Error?) -> Void) {
        deptRef()?.child(department.department_id!).updateChildValues(department.dictionaryData(), withCompletionBlock: { (error, reference) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(department, nil)
        })
    }
    
    func getDepartmentList(completion:@escaping ([Department]?, Error?) -> Void) {
        deptRef()?.observeSingleEvent(of: .value, with: { SnapShot in
            var list: [Department] = []
            for child in SnapShot.children {
                let data = child as? DataSnapshot
                guard let dept = Department.get(data: data?.value as! NSDictionary) else {
                    let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "部門資料格式錯誤"])
                    completion(nil, error)
                    return
                }
                list.append(dept)
            }
            self.mDeptList = list
            completion(list, nil)
        })
    }
    
    func staffList() -> [Staff]? {
        return mStaffList
    }
    
    func managerList() -> [Staff]? {
        guard let staffs = staffList() else { return nil }
        return staffs.filter { (staff) -> Bool in
            (staff.role?.isManager())!
        }
    }
    
    func coworkerList() -> [Staff]? {
        guard let staffs = staffList() else { return nil }
        return staffs.filter({ (staff) -> Bool in
            (staff.sid != currentStaff?.sid) &&
                (staff.department == currentStaff?.department) &&
                    (staff.quitDate == nil)
        })
    }
    
    func departmentList() -> [Department]? {
        return mDeptList
    }
    
    func getStaff(byStaffId staffId: String) -> Staff? {
        guard let staffs = self.staffList() else { return nil }
        let result = staffs.filter({ (staff) -> Bool in
            staff.sid == staffId
        })
        return result.first
    }
    
    func getStaff(byName name: String) -> Staff? {
        guard let staffs = self.staffList() else { return nil }
        let result = staffs.filter({ (staff) -> Bool in
            staff.name == name
        })
        return result.first
    }
    
    func getManager(byStaffId staffId: String) -> Staff? {
        guard let managers = self.managerList() else { return nil }
        let result = managers.filter({ (staff) -> Bool in
            staff.sid == staffId
        })
        return result.first
    }
    
    func getManager(byStaffName name: String) -> Staff? {
        guard let managers = self.managerList() else { return nil }
        let result = managers.filter({ (staff) -> Bool in
            staff.name == name
        })
        return result.first
    }
    
    func getDepartment(byID departmentId: String) -> Department? {
        guard let depts = self.departmentList() else { return nil }
        let result = depts.filter({ (dept) -> Bool in
            dept.department_id == departmentId
        })
        return result.first
    }
    
    func getDepartment(byName name: String) -> Department? {
        guard let depts = self.departmentList() else { return nil }
        let result = depts.filter({ (dept) -> Bool in
            dept.title == name
        })
        return result.first
    }
    
    // MARK: Private Getter
    private func staffRef() -> DatabaseReference? {
        return self.dbRef?.child(tbDefines.kStaff)
    }
    
    private func deptRef() -> DatabaseReference? {
        return self.dbRef?.child(tbDefines.kDepartment)
    }
}
