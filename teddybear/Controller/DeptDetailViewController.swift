//
//  DeptDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class DeptDetailViewController: UITableViewController
, UITextFieldDelegate {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var supervisorField: UITextField!
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var pickerView: tbPickerView!
    
    private var mFields: [UITextField]?
    private func fields() -> [UITextField] {
        if mFields == nil {
            mFields = [titleField, supervisorField, keyField]
        }
        return mFields!
    }
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    var currentDepartment: Department?
    
    private func dataSource() -> [String]? {
        guard let list = manager?.managerList() else { return nil }
        return list.map({ (staff) -> String in
            return staff.name!
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = (currentDepartment == nil ? "新增員工" : currentDepartment?.title)
        
        setupLayout()
        layoutWithDept(currentDepartment)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    func layoutWithDept(_ dept: Department?) {
        guard let dept = dept else { return }
        titleField.text = dept.title
        supervisorField.text = manager?.getManager(byStaffId:dept.supervisor!)?.name
        keyField.text = dept.department_id
        keyField.isEnabled = false
        sendBtn.setTitle("確定修改", for: .normal)
        
        self.textFieldDidChanged(field: titleField) //forced validation
    }
    
    //MARK: Action
    @IBAction func onUpdateDept() {
        
        if (titleField.isStringCountValid(text: titleField.text!) &&
            supervisorField.isStringCountValid(text: supervisorField.text!) &&
            keyField.isKeyValid(text:keyField.text!)){
        
        var _dept = Department()
        _dept.title = titleField.text
        _dept.supervisor = manager?.getManager(byStaffName:supervisorField.text!)?.sid
        _dept.department_id = keyField.text
        
        tbHUD.show()
        manager?.updateDepartment(_dept) { (department, error) in
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
    
    //MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        sendBtn.isEnabled = fieldsValidation()
        sendBtn.backgroundColor = sendBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == supervisorField {
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
            if 0 == field.text?.count { return false }
        }
        return true
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let field = fields()[indexPath.row]
        field.becomeFirstResponder()
    }
}
