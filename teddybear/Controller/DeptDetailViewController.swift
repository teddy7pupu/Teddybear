//
//  DeptDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class DeptDetailViewController: UITableViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var supervisorField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    private var mFields: [UITextField]?
    private func fields() -> [UITextField] {
        if mFields == nil {
            mFields = [titleField, supervisorField]
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
    
    @IBAction func onUpdateDept() {
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        sendBtn.isEnabled = fieldsValidation()
        sendBtn.backgroundColor = sendBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == supervisorField {
            //supervisor list
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
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
        let field = fields()[indexPath.row]
        field.becomeFirstResponder()
    }
}
