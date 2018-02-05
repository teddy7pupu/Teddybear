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
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var coworkerList: [Staff]? =  StaffManager.sharedInstance().coworkerList()
    private var staffList: [Staff]? = []
    private var staffLeaveList: [[Leave]]? = [] //放每個員工的假單, 位置對應到staffList
    private var passLeaveList: [Leave]? = [] //放有成立的假單

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
        tbHUD.show()
        getMonthList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueReport {
            let detailView = segue.destination as! ReportDetailViewController
            let count = sender as! Int
            let staff = staffList?[count]
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
    func getMonthList() {
        getStaffList()
        let nowYear: Int = Calendar.current.component(.year, from: Date())
        let nowMonth: Int = Calendar.current.component(.month, from: Date())
        let start = getStartAndEndTime(stringDate: "\(nowYear)-\(nowMonth)")[0]
        let end = getStartAndEndTime(stringDate: "\(nowYear)-\(nowMonth)")[1]
        self.getRangeLeaveList(start, end)
    }
    
    func getStaffList() {
        if coworkerList == nil {
            manager?.getStaffList(completion: { (list, error) in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                self.coworkerList = list
                self.getStaffList()
            })
            return
        }
    }
    
    //輸入開始和結束的時間拿這個區間的假單
    func getRangeLeaveList(_ start: Int, _ end: Int){
        LeaveManager.sharedInstance().getRangeLeaveList(start, end,completion: { (list, error) in
            if error != nil { return }
            self.passLeaveList = self.filterPassLeave(leaves: list)
            self.getStaffLeaves()
        })
    }
    
    func getStaffLeaves() {
        staffList = []
        staffLeaveList = []
        for staff in coworkerList!{
            var staffLeaves: [Leave] = []
            for leave in passLeaveList! {
                if staff.sid == leave.sid {
                    staffLeaves.append(leave)
                }
            }
            if staffLeaves.isEmpty != true {
                staffList?.append(staff)
                staffLeaveList?.append(staffLeaves)
            }
        }
        
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        tbHUD.dismiss()
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
    
    func getStartAndEndTime(stringDate: String) -> [Int] {
        let startDate = Date(fromString: "\(stringDate)-01", format: .isoDate)
        let startYear: Int = Calendar.current.component(.year, from: startDate!)
        let startMonth: Int = Calendar.current.component(.month, from: startDate!)
        var endYear = 0
        var endmonth = 0
        if (startMonth + 1) > 12 {
            endmonth = 1
            endYear = startYear + 1
        }
        else {
            endmonth = startMonth + 1
            endYear = startYear
        }
        let endDate = Date(fromString: "\(endYear)-\(endmonth)-01", format: .isoDate)
        return [Int((startDate?.timeIntervalSince1970)!),Int((endDate?.timeIntervalSince1970)!)]
    }
    
    @IBAction func onSelectMonth() {
        dateField.becomeFirstResponder()
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = staffList?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        if (self.staffLeaveList?.count)! - 1 >= indexPath.row {
            cell.layoutCell(with: staffList?[indexPath.row], leaves: self.staffLeaveList?[indexPath.row])
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
            let start = getStartAndEndTime(stringDate: text)[0]
            let end = getStartAndEndTime(stringDate: text)[1]
            self.getRangeLeaveList(start, end)
        }
    }
}

