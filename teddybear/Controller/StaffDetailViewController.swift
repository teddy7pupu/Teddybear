//
//  StaffDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class StaffDetailViewController: UITableViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var englishField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var birthdayField: UITextField!
    @IBOutlet weak var onboardField: UITextField!
    @IBOutlet weak var deptField: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    private var mFields: [[UITextField]]?
    private func fields() -> [[UITextField]] {
        if mFields == nil {
            mFields = [[nameField, englishField, mailField, phoneField, birthdayField, onboardField], [deptField, titleField]]
        }
        return mFields!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
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
    
    //MARK: Action
    @IBAction func onCreateStaff() {
        var _staff = Staff()
        _staff.name = nameField.text
        _staff.english = englishField.text
        _staff.email = mailField.text
        _staff.mobile = phoneField.text
        //_staff = birthdayField.text
        //_staff = onboardField.text
        _staff.department = deptField.text
        _staff.title = titleField.text
        StaffManager.sharedInstance().createStaff(staff: _staff) { (staff, error) in

        }
    }
    
    @IBAction func textFieldDidChanged(field: UITextField) {
        sendBtn.isEnabled = fieldsValidation()
        sendBtn.backgroundColor = sendBtn.isEnabled ? tbDefines.colorFBLUE : UIColor.lightGray
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
