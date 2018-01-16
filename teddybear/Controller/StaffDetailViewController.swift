//
//  StaffDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class StaffDetailViewController: UITableViewController
, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var englishField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var onboardField: UITextField!
    @IBOutlet weak var deptField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var sidField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var datePickerView: DatePickerView!
    
    private var mFields: [[UITextField]]?
    private func fields() -> [[UITextField]] {
        if mFields == nil {
            mFields = [[nameField, englishField, mailField, phoneField, birthdayField, onboardField], [deptField, titleField, sidField]]
        }
        return mFields!
    }
    
    var currentStaff: Staff?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (currentStaff == nil ? "新增員工" : currentStaff?.name)
        
        setupLayout()
        layoutWithStaff(currentStaff)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(StaffDetailViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    func layoutWithStaff(_ staff: Staff?) {
        guard let staff = staff else { return }
        nameField.text = staff.name
        englishField.text = staff.english
        mailField.text = staff.email
        phoneField.text = staff.mobile
        birthdayField.text = Date(timeIntervalSince1970: TimeInterval(staff.birthday!)).toString(format: .isoDate)
        onboardField.text = Date(timeIntervalSince1970: TimeInterval(staff.onBoardDate!)).toString(format: .isoDate)
        deptField.text = staff.department
        titleField.text = staff.title
        sidField.text = staff.sid
        sidField.isEnabled = false
        sendBtn.setTitle("確定修改", for: .normal)
        
        self.textFieldDidChanged(field: titleField) //forced validation
    }
    
    //MARK: Action
    @IBAction func onCreateStaff() {
        var _staff = Staff()
        _staff.name = nameField.text
        _staff.english = englishField.text
        _staff.email = mailField.text
        _staff.mobile = phoneField.text
        let birthday = Date(fromString: birthdayField.text!, format: .isoDate)!
        _staff.birthday = Int(birthday.timeIntervalSince1970)
        let onBoardDate = Date(fromString: onboardField.text!, format: .isoDate)!
        _staff.onBoardDate = Int(onBoardDate.timeIntervalSince1970)
        _staff.department = deptField.text
        _staff.title = titleField.text
        _staff.sid = String.init(format: "M%03ld", Int(sidField.text!)!)
        StaffManager.sharedInstance().updateStaff(_staff) { (staff, error) in
            if let error = error {
                NSLog("%@", error.localizedDescription)
                UIAlertController.alert(message: "資料更新失敗").otherHandle(alertAction: nil).show(currentVC: self)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        sendBtn.isEnabled = fieldsValidation()
        sendBtn.backgroundColor = sendBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
        if field == sidField, let number = Int(field.text!) {
            field.text = String.init(format: "%ld", number)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == birthdayField || textField == onboardField {
            textField.inputView = datePickerView
            datePickerView.owner = textField
        }
        return true
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: Data
    func fieldsValidation() -> Bool {
        for group in fields() {
            for field in group {
                if 0 == field.text?.count { return false }
            }
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let field = fields()[indexPath.section][indexPath.row]
        field.becomeFirstResponder()
    }
}