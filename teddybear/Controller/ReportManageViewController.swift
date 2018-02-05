//
//  ReportManageViewController.swift
//  teddybear
//
//  Created by msp310 on 2018/2/1.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportManageViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var pickerView: MonthYearPickerView!
    @IBOutlet weak var dateField: UITextField!
    private var list: [Staff]? = []
    private var staffLeaveList: [[Leave]]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "假勤報表"
        setupLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStaffList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueReport {
            let detailView = segue.destination as! ReportDetailViewController
            let count = sender as! Int
            let staff = list?[count]
            let leaves = staffLeaveList?[count]
            detailView.staffName = staff?.name
            detailView.staffLeaves = leaves
        }
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        dateField.inputView = pickerView
        pickerView.owner = dateField
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ReportManageViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    //MARK: Action
    func getStaffList() {
        tbHUD.show()
        StaffManager.sharedInstance().getStaffList { (list, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
            self.list = list
            self.getStaffLeaves(staffList: list)
        }
    }
    
    func getStaffLeaves(staffList: [Staff]?) {
        var count: Int = 0
        for staff in staffList!{
            LeaveManager.sharedInstance().getLeaveList(staff.sid, completion: { (list, error) in
                tbHUD.dismiss()
                let passLeaves = self.filterPassLeave(leaves: list)
                if passLeaves?.count == 0 {
                    self.list?.remove(at: count)
                }
                else {
                    self.staffLeaveList?.append(passLeaves!)
                    count += 1
                }
                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
    }
    
    func filterPassLeave(leaves: [Leave]?) -> [Leave]?{
        var returnList: [Leave]? = []
        for leave in leaves! {
            var passStatus: Int = 0
            for approval in leave.approvals! {
                if approval.status == 1 { passStatus += 1}
                if passStatus == 2 { returnList?.append(leave) }
            }
        }
        return returnList
    }
    
    func getMonthDataSource() -> [String] {
        let month: Int = Calendar.current.component(.month, from: Date())
        var lastMonth: Int = month - 1
        if lastMonth == 0 { lastMonth = 12 }
        var twoLastMonth: Int = lastMonth - 1
        if twoLastMonth == 0 { twoLastMonth = 12 }
        return [String(twoLastMonth), String(lastMonth), String(month)]
    }
    
    @IBAction func onSelectMonth() {
        dateField.becomeFirstResponder()
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = list?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        if (self.staffLeaveList?.count)! - 1 >= indexPath.row {
            cell.layoutCell(with: list?[indexPath.row], leaves: self.staffLeaveList?[indexPath.row])
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueReport, sender: indexPath.row)
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        if field == dateField {
            guard let text = field.text, !text.isEmpty else {
                monthButton.setTitle("選擇月份", for: .normal)
                return
            }
            monthButton.setTitle(("\(text)"), for: .normal)
        }
    }
}

