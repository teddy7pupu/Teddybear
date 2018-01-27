//
//  LeaveDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/27.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class LeaveDetailViewController: UITableViewController
, UITextFieldDelegate {

    @IBOutlet weak var beginTimeField: UITextField!
    @IBOutlet weak var beginPeriodField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var endPeriodField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var assigneeField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var datePickerView: DatePickerView!
    @IBOutlet weak var pickerView: tbPickerView!
    
    private var mFields: [UITextField]?
    private func fields() -> [UITextField] {
        if mFields == nil {
            mFields = [beginTimeField, beginPeriodField, endTimeField, endPeriodField, typeField, assigneeField, messageField]
        }
        return mFields!
    }
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var coworkerList: [Staff]? = StaffManager.sharedInstance().coworkerList()
    var currentLeave: Leave?
    
    private func dataSource() -> [String]? {
        guard let list = coworkerList else { return nil }
        return list.map({ (staff) -> String in
            return staff.name!
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (currentLeave == nil ? "新增假單" : currentLeave?.type)
        setupLayout()
        getStaffList { (error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
            }
            self.layoutLeave(leave: self.currentLeave)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(LeaveDetailViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    func layoutLeave(leave: Leave?) {
        guard let leave = leave else { return }
        
        beginTimeField.text = Date(timeIntervalSince1970: TimeInterval(leave.startTime!)).toString(format: .isoDate)
        beginPeriodField.text = tbDefines.kBeginSection[leave.startPeriod!]
        endTimeField.text = Date(timeIntervalSince1970: TimeInterval(leave.endTime!)).toString(format: .isoDate)
        endPeriodField.text = tbDefines.kEndSection[leave.endPeriod!]
        typeField.text = leave.type
        assigneeField.text = manager?.getStaff(byStaffId: leave.assigneeId!)?.name
        messageField.text = leave.message
        sendBtn.setTitle("確定修改", for: .normal)
        
        self.textFieldDidChanged(field: messageField)
    }
    
    //MARK: Action
    func getStaffList(completion:@escaping (Error?) -> Void) {
        if coworkerList == nil {
            manager?.getStaffList(completion: { (list, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.coworkerList = self.manager?.coworkerList()
                completion(nil)
            })
        } else {
            completion(nil)
        }
    }
    
    @IBAction func onUpdateLeave() {
        let beginDate = Date(fromString: beginTimeField.text!, format: .isoDate)!
        let beginPeriod = tbDefines.kBeginSection.index(of: beginPeriodField.text!)
        let endDate = Date(fromString: endTimeField.text!, format: .isoDate)!
        let endPeriod = tbDefines.kEndSection.index(of: endPeriodField.text!)
        guard Date.leaveHour(beginDate, beginPeriod!, endDate, endPeriod!) > 0 else {
            self.showAlert(message: "假勤時間輸入錯誤")
            return
        }
        
        var leave = Leave(leaveId: LeaveManager.sharedInstance().getAutoKey()!)
        leave.startTime = Int(beginDate.timeIntervalSince1970)
        leave.startPeriod = beginPeriod
        leave.endTime = Int(endDate.timeIntervalSince1970)
        leave.endPeriod = endPeriod
        leave.type = typeField.text
        let assignee = manager?.getStaff(byName: assigneeField.text!)
        leave.assigneeId = assignee?.sid
        leave.message = messageField.text
        
        leave.sid = manager?.currentStaff?.sid
        leave.deparmentId = manager?.currentStaff?.department
        leave.applyTime = Int(Date().timeIntervalSince1970)
        
        tbHUD.show()
        LeaveManager.sharedInstance().updateLeaveData(leave) { (leave, error) in
            tbHUD.dismiss()
            if let error = error {
                NSLog("%@", error.localizedDescription)
                self.showAlert(message: "資料更新失敗")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        sendBtn.isEnabled = fieldsValidation()
        sendBtn.backgroundColor = sendBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == beginTimeField || textField == endTimeField {
            textField.inputView = datePickerView
            datePickerView.owner = textField
        }
        if textField == beginPeriodField || textField == endPeriodField {
            textField.inputView = pickerView
            pickerView.dataSource = (textField == beginPeriodField ? tbDefines.kBeginSection : tbDefines.kEndSection)
            pickerView.owner = textField
        }
        if textField == typeField {
            textField.inputView = pickerView
            pickerView.dataSource = tbDefines.kLeaveType
            pickerView.owner = textField
        }
        if textField == assigneeField {
            textField.inputView = pickerView
            pickerView.dataSource = dataSource()
            pickerView.owner = textField
        }
        return true
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Data
    func fieldsValidation() -> Bool {
        for field in fields() {
            if (field.text?.isEmpty)! { return false }
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let field = fields()[indexPath.row]
            field.becomeFirstResponder()
        }
    }
}
