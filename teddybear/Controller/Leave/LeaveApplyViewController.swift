//
//  LeaveApplyViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/3/4.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class LeaveApplyViewController: UITableViewController
, UITextFieldDelegate {

    @IBOutlet weak var typeField: UITextField?
    @IBOutlet weak var beginDateField: UITextField?
    @IBOutlet weak var beginTimeField: UITextField?
    @IBOutlet weak var endDateField: UITextField?
    @IBOutlet weak var endTimeField: UITextField?
    @IBOutlet weak var summationLbl: UILabel?
    @IBOutlet weak var assigneeField: UITextField?
    @IBOutlet weak var messageField: UITextField?
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pickerView: tbPickerView?
    @IBOutlet weak var datePickerView: DatePickerView?
    
    private var fields: [UITextField?] = []
    private var coworkerList: [Staff]?
    
    var applyLeave: Leave?
    internal enum ApplyStatus: Int {
        case step1
        case step2
        case step3
        
        static func status(leave: Leave?) -> ApplyStatus {
            if leave == nil { return .step1 }
            if leave?.startTime == nil { return .step2 }
            return .step3
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupField()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardDismiss(gesture:nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextVC = segue.destination as? LeaveApplyViewController else { return }
        
        if segue.identifier == "SegueStep2" {
            applyLeave = Leave()
            applyLeave?.type = Leave.LeaveType(rawValue: (typeField?.text)!)
        } else if segue.identifier == "SegueStep3" {
            let begin = "\((beginDateField?.text)!) \((beginTimeField?.text)!)"
            let end = "\((endDateField?.text)!) \((endTimeField?.text)!)"
            applyLeave?.startTime = Int((Date(fromString:begin , format: .custom("yyyy-MM-dd HH:mm"))?.timeIntervalSince1970)!)
            applyLeave?.endTime = Int((Date(fromString:end , format: .custom("yyyy-MM-dd HH:mm"))?.timeIntervalSince1970)!)
        }
        nextVC.applyLeave = applyLeave
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    internal func setupLayout() {
        
    }
    
    internal func setupField() {
        let status = ApplyStatus.status(leave: applyLeave)
        switch status {
        case .step1:
            fields.append(typeField)
            typeField?.becomeFirstResponder()
            return
        case .step2:
            fields.append(beginDateField)
            fields.append(beginTimeField)
            fields.append(endDateField)
            fields.append(endTimeField)
            beginDateField?.becomeFirstResponder()
            return
        default:
            fields.append(assigneeField)
            fields.append(messageField)
            getCoworkers()
        }
    }
    
    //MARK: Action
    internal func getCoworkers() {
        let manager = StaffManager.sharedInstance()
        if let list = manager.coworkerList() {
            coworkerList = list
            self.assigneeField?.becomeFirstResponder()
            return
        }
        
        tbHUD.show()
        manager.getStaffList(completion: { list, error in
            tbHUD.dismiss()
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: error.localizedDescription, completion: {
                        self.getCoworkers()
                    })
                }
                return
            }
            self.coworkerList = manager.coworkerList()
            DispatchQueue.main.async {
                self.assigneeField?.becomeFirstResponder()
            }
        })
    }
    
    @IBAction func onSubmitLeave() {
        let staffManager = StaffManager.sharedInstance()
        let assignee = staffManager.getStaff(byName: (assigneeField?.text)!)
        applyLeave?.assigneeId = assignee?.sid
        applyLeave?.message = messageField?.text
        
        let manager = LeaveManager.sharedInstance()
        applyLeave?.leaveId = manager.getAutoKey()
        applyLeave?.applyTime = Int(Date().timeIntervalSince1970)
        applyLeave?.sid = staffManager.currentStaff?.sid
        applyLeave?.departmentId = staffManager.currentStaff?.department
        
        tbHUD.show()
        manager.updateLeaveData(applyLeave) { leave, error in
            tbHUD.dismiss()
            if let error = error {
                NSLog("%@", error.localizedDescription)
                self.showAlert(message: "資料更新失敗")
                return
            }
            DispatchQueue.main.async {
                self.closeView()
            }
        }
    }
    
    @IBAction func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == typeField {
            textField.inputView = pickerView
            pickerView?.dataSource = Leave.LeaveType.allValues.map{ $0.rawValue }
            pickerView?.owner = textField
        } else if textField == beginDateField || textField == endDateField {
            textField.inputView = datePickerView
            datePickerView?.owner = textField
        } else if textField == beginTimeField || textField == endTimeField {
            textField.inputView = pickerView
            if applyLeave?.type == .annual {
                pickerView?.type = (textField == beginTimeField) ? .AnnualSection1 : .AnnualSection2
            } else {
                pickerView?.type = .OfficeHour
            }
            pickerView?.owner = textField
        } else if textField == assigneeField {
            textField.inputView = pickerView
            pickerView?.dataSource = coworkerList?.map{ $0.name! }
            pickerView?.owner = textField
        } else {
            textField.inputView = nil
        }
        return true
    }
    
    @IBAction func textFieldDidChanged(field: UITextField) {
        nextBtn.isEnabled = fieldsValidation()
        nextBtn.backgroundColor = nextBtn.isEnabled ? UIColor.SPGreen : UIColor.SPLight

        if summationLbl != nil {
            guard nextBtn.isEnabled,
            let _beginDate = beginDateField?.text,
            let _beginTime = beginTimeField?.text,
            let _endDate = endDateField?.text,
            let _endTime = endTimeField?.text else {
                summationLbl?.text = "總計: 無法計算"
                return
            }
            let begin = "\(_beginDate) \(_beginTime)"
            let end = "\(_endDate) \(_endTime)"
            let beginDate = Date(fromString:begin, format: .custom("yyyy-MM-dd HH:mm"))
            let endDate = Date(fromString:end, format: .custom("yyyy-MM-dd HH:mm"))
            let hour = Date.leaveHour(beginDate!, endDate!)
            if hour < 1 {
                summationLbl?.text = "總計: 無法計算"
                nextBtn.isEnabled = false
                return
            }
            summationLbl?.text = "總計: \(hour/8) 天  \(hour%8) 小時"
        }
    }
    
    internal func fieldsValidation() -> Bool {
        for field in fields {
            if field?.text?.count == 0 {
                return false
            }
        }
        return true
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        
        guard indexPath.row < fields.count, let field = fields[indexPath.row] else { return }
        field.becomeFirstResponder()
    }
}
