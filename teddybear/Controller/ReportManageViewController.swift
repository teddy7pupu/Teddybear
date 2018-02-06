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
    
    private var stafflist: [Staff]?
    private var passLeaveList: [Leave]? = [] //放有成立的假單
    private var staffsLeaves: Dictionary<String, Any> = [:]
    private var staffLeaveListArray: [Dictionary<String, Any>] = []

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
        getMonthList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueReport {
            let detailView = segue.destination as! ReportDetailViewController
            for (staffSid, leaves) in sender as! Dictionary<String, Any> {
                for staff in stafflist! {
                    if staff.sid == staffSid { detailView.staffName = staff.name }
                }
                detailView.staffLeaves = leaves as? [Leave]
            }
        }
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        dateField.inputView = pickerView
        pickerView.owner = dateField
        
        let nowYear: Int = Calendar.current.component(.year, from: Date())
        let nowMonth: Int = Calendar.current.component(.month, from: Date())
        monthButton.setTitle("\(nowYear)-\(nowMonth)", for: .normal)
        
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
        if stafflist == nil {
            StaffManager.sharedInstance().getStaffList { (list, error) in
                if let error = error {
                    NSLog(error.localizedDescription)
                    return
                }
                self.stafflist = list
                self.getStaffList()
            }
        }
    }
    
    //輸入開始和結束的時間拿這個區間的假單
    func getRangeLeaveList(_ start: Int, _ end: Int){
        LeaveManager.sharedInstance().getRangeLeaveList(start, end,completion: { (list, error) in
            if error != nil { return }
            self.filterPassLeave(leaves: list)
            self.mapping()
        })
    }
    
    //過濾出成立假單
    func filterPassLeave(leaves: [Leave]?){
        var list: [Leave]? = []
        for leave in leaves! {
            guard let approvals = leave.approvals else { continue }
            if approvals.count > 1 && approvals[1].status == 1 {
                list?.append(leave)
            }
        }
        self.passLeaveList = list
    }
    
    //假單和員工分類成字典
    func mapping(){
        staffsLeaves = [:]
        staffLeaveListArray = []
        for staff in stafflist! {
            var list: [Leave]? = []
            for leave in passLeaveList! {
                if staff.sid == leave.sid { list?.append(leave) }
            }
            if list?.isEmpty == false {
                staffsLeaves["\(staff.sid!)"] = list
            }
        }
        
        for  (staff, leaves) in staffsLeaves {
            staffLeaveListArray.append([staff:leaves])
        }
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
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
        return staffLeaveListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        for (staffSid, leaves) in staffLeaveListArray[indexPath.row] {
            for staff in stafflist! {
                if staff.sid == staffSid { cell.layoutCell(staff: staff, leaves: leaves as? [Leave] ) }
            }
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueReport, sender: staffLeaveListArray[indexPath.row])
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

