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
    @IBOutlet weak var manageSwitch: UISwitch!
    @IBOutlet weak var accountSwitch: UISwitch!
    @IBOutlet weak var internSwitch: UISwitch!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var datePickerView: DatePickerView!
    @IBOutlet weak var pickerView: tbPickerView!
    
    private var mFields: [[UITextField]]?
    private func fields() -> [[UITextField]] {
        if mFields == nil {
            mFields = [[nameField, englishField, mailField, phoneField, birthdayField, onboardField], [deptField, titleField, sidField]]
        }
        return mFields!
    }
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var deptList: [Department]? = StaffManager.sharedInstance().departmentList()
    var currentStaff: Staff?
    
    private func dataSource() -> [String]? {
        guard let list = deptList else { return nil }
        return list.map({ (dept) -> String in
            return dept.title!
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (currentStaff == nil ? "新增員工" : currentStaff?.name)
        
        setupLayout()
        getDepartments { (error) in
            self.layoutWithStaff(self.currentStaff)
        }
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
        deptField.text = manager?.getDepartment(byID:staff.department!)?.title
        titleField.text = staff.title
        sidField.text = staff.sid
        sidField.isEnabled = false
        manageSwitch.isOn = (staff.role?.isManager())!
        accountSwitch.isOn = (staff.role?.isAccount())!
        internSwitch.isOn = (staff.role?.isIntern())!
        accountSwitch.isEnabled = { () -> Bool in
            staff.uid != UserManager.currentUser()?.uid
        }()
        sendBtn.setTitle("確定修改", for: .normal)
        
        self.textFieldDidChanged(field: titleField) //forced validation
        
    }

    //MARK: Action
    @IBAction func onUpdateStaff() {
    
        if (nameField.isStringCountValid(text: nameField.text!) &&
            englishField.isStringCountValid(text: englishField.text!) &&
            mailField.isEmailValid(text: mailField.text!) &&
            phoneField.isPhoneValid(text: phoneField.text!) &&
            birthdayField.isDateValid(text: birthdayField.text!) &&
            onboardField.isDateValid(text: onboardField.text!) &&
            titleField.isStringCountValid(text: titleField.text!) &&
            sidField.isSidValid(text: sidField.text!)){
            
            var _staff = Staff()
            _staff.name = nameField.text
            _staff.english = englishField.text
            _staff.email = mailField.text
            _staff.mobile = phoneField.text
            let birthday = Date(fromString: birthdayField.text!, format: .isoDate)!
            _staff.birthday = Int(birthday.timeIntervalSince1970)
            let onBoardDate = Date(fromString: onboardField.text!, format: .isoDate)!
            _staff.onBoardDate = Int(onBoardDate.timeIntervalSince1970)
            _staff.department = manager?.getDepartment(byName:deptField.text!)?.department_id
            _staff.title = titleField.text
            if let number = Int(sidField.text!) {
                _staff.sid = String.init(format: "M%03ld", number)
            } else {
                _staff.sid = sidField.text!
            }
            _staff.role?.setRole(manageSwitch.isOn, accountSwitch.isOn, internSwitch.isOn)
            
            
            tbHUD.show()
            manager?.updateStaff(_staff) { (staff, error) in
                tbHUD.dismiss()
                if let error = error {
                    NSLog("%@", error.localizedDescription)
                    self.showAlert(message: "資料更新失敗")
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
            
            
        }else{
                self.showAlert(message: "請輸入正確資料")
        }
    }
    
    func getDepartments(completion:@escaping (Error?) -> Void) {
        if deptList == nil {
            manager?.getDepartmentList(completion: { (list, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.deptList = list
                completion(nil)
            })
        } else {
            completion(nil)
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
            datePickerView.maximumDate = Date()
            datePickerView.owner = textField
        }
        if textField == deptField {
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
        for group in fields() {
            for field in group {
                if (field.text?.isEmpty)! { return false }
            }
        }
        return true
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        if indexPath.row < 6 { //row[7,8] are UserRole switch
            let field = fields()[indexPath.section][indexPath.row]
            field.becomeFirstResponder()
        }
    }
}
