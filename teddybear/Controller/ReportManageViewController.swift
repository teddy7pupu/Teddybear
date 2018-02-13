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
    @IBOutlet weak var pickerView: tbPickerView!
    @IBOutlet weak var dateField: UITextField!
    
    private weak var manager = StaffManager.sharedInstance()
    private var passLeaveList: [Leave]? = []
    private var staffsLeaves: Dictionary<String, [Leave]?> = [:]
    private var staffsLeaveHours: Dictionary<String, String> = [:]
    
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
        getStaffList()
        getMonthList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueReport {
            let detailView = segue.destination as! ReportDetailViewController
            let staffId = sender as? String
            let leaves = staffsLeaves[staffId!]
            let staff = manager?.getStaff(byStaffId: staffId!)
            detailView.staffName = staff?.name
            detailView.staffLeaves = leaves!
        }
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        dateField.inputView = pickerView
        pickerView.type = .MonthYear
        pickerView.owner = dateField
        
        let current = Date().toString(format: .isoYearMonth)
        monthButton.setTitle("\(current)", for: .normal)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ReportManageViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    //MARK: Action
    func csvFileOut(path: URL?){
        var csvText = "姓名,假別,開始時間,結束時間,小計,總計\n"
        for (staffSid, leaves) in staffsLeaves {
            if let staffName = manager?.getStaff(byStaffId: staffSid)?.name{
                csvText.append("\(staffName),")
            }
            var totalHour = 0
            for leave in leaves! {
                let type = leave.type!
                let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
                let finishDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
                let hour = Date.leaveHour(beginDate, leave.startPeriod!, finishDate, leave.endPeriod!)
                totalHour += hour
                let startDay = String(Calendar.current.component(.day, from: beginDate))
                let startMonth = String(Calendar.current.component(.month, from: beginDate))
                let startPeriod = tbDefines.kBeginSection[leave.startPeriod!]
                let endDay = String(Calendar.current.component(.day, from: finishDate))
                let endMonth = String(Calendar.current.component(.month, from: finishDate))
                let endPeriod = tbDefines.kEndSection[leave.endPeriod!]
                csvText.append("\(type),\(startMonth)月\(startDay)日\(startPeriod),\(endMonth)月\(endDay)日\(endPeriod),\(hour)小時\n")
            }
            csvText.append(",,,,,總共\(totalHour)小時\n")
        }
        let vc = UIActivityViewController(activityItems: [path as Any], applicationActivities: [])
        vc.excludedActivityTypes = [UIActivityType.assignToContact
            ,UIActivityType.saveToCameraRoll
            ,UIActivityType.postToFlickr
            ,UIActivityType.postToVimeo
            ,UIActivityType.postToTencentWeibo
            ,UIActivityType.postToTwitter
            ,UIActivityType.postToFacebook
            ,UIActivityType.openInIBooks]
        present(vc, animated: true, completion: nil)
        do {
            try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            showAlert(message: "Failed to create file")
        }
        //tbHUD.dismiss()
    }
    
    @IBAction func onOutPut(_ sender: Any) {
        //tbHUD.show()
        if let time = monthButton.titleLabel?.text {
            let fileName = "\(time)假勤報表.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            csvFileOut(path: path)
        }
    }
    
    func getMonthList() {
        let start = startMonth(yearMonth: (monthButton.titleLabel?.text)!).timeIntervalSince1970
        let end = endMonth(yearMonth: (monthButton.titleLabel?.text)!).timeIntervalSince1970
        self.getRangeLeaveList(Int(start), Int(end))
    }
    
    func getStaffList() {
        guard manager?.staffList() != nil else {
            manager?.getStaffList { (list, error) in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                }
            }
            return
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
        staffsLeaveHours = [:]
        for leave in passLeaveList! {
            if staffsLeaves[leave.sid!] == nil {
                staffsLeaves[leave.sid!] = [leave]
            } else {
                var tmp = staffsLeaves[leave.sid!]!
                tmp?.append(leave)
                staffsLeaves[leave.sid!] = tmp
            }
        }
        for staffId in staffKeys()!{
            staffsLeaveHours[staffId] = getTotalHours(leaves: staffsLeaves[staffId]!)
        }
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        tbHUD.dismiss()
    }
    
    func getTotalHours(leaves: [Leave]?) -> String {
        var summation: Int = 0
        for leave in leaves! {
            let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
            let endDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
            let hour = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
            summation += hour
        }
        return summation > 8 ? String(format:"%.1f天", Double(summation)/8) : "\(summation)小時"
    }
    
    func startMonth(yearMonth: String) -> Date {
        var format: DateFormatType = .isoDate
        if DateFormatter().locale.identifier == "zh_TW"{
            format = .isoCHDate
        }
        let startOfMonth = Date(fromString: "\(yearMonth)-01", format: format)
        return startOfMonth!
    }
    
    func endMonth(yearMonth: String) -> Date {
        var components = DateComponents()
        components.month = 1
        components.day = -1
        let endOfMonth =  NSCalendar.current.date(byAdding: components, to: startMonth(yearMonth: yearMonth))!
        return endOfMonth
    }
    
    @IBAction func onSelectMonth() {
        dateField.becomeFirstResponder()
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = staffKeys()?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        let staffId = staffKeys()?[indexPath.row]
        let leaves = staffsLeaves[staffId!]
        let staff = manager?.getStaff(byStaffId: staffId!)
        let total = staffsLeaveHours[staffId!]
        cell.layoutCell(staff: staff!, leavesCount: (leaves!!.count), total: total!)
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueReport, sender: staffKeys()?[indexPath.row])
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        if field == dateField {
            guard let text = field.text, !text.isEmpty else {
                return
            }
            tbHUD.show()
            let startDate = startMonth(yearMonth: text)
            let title = startDate.toString(format: .isoYearMonth)
            monthButton.setTitle(("\(title)"), for: .normal)
            let start = startDate.timeIntervalSince1970
            let end = endMonth(yearMonth: text).timeIntervalSince1970
            self.getRangeLeaveList(Int(start), Int(end))
        }
    }
    
    //MARK: Getter
    private func staffKeys() -> [String]? {
        return Array(staffsLeaves.keys)
    }
}
