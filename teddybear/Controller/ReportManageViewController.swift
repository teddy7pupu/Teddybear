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
    private var staffsLeaves: Dictionary<String, [Leave]?> = [:]
    
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
            let staffId = sender as? String
            let leaves = staffsLeaves[staffId!]
            let staff = getStaff(staffId: staffId!)
            detailView.staffName = staff?.name
            detailView.staffLeaves = leaves!
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
    func writeText(path: URL?){
        var csvText = "姓名,假別,開始時間,結束時間,小計,總計\n"
        for (staffSid, leaves) in staffsLeaves {
            for staff in stafflist! {
                if staffSid == staff.sid { csvText.append("\(staff.name!),") }
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
            csvText.append(",,,,總共\(totalHour)小時\n")
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
    }
    
    @IBAction func onOutPut(_ sender: Any) {
        if let time = monthButton.titleLabel?.text {
            let fileName = "\(time)假勤報表.csv"
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            writeText(path: path)
        }
    }
    
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
        for leave in passLeaveList! {
            if staffsLeaves[leave.sid!] == nil {
                staffsLeaves[leave.sid!] = [leave]
            } else {
                var tmp = staffsLeaves[leave.sid!]!
                tmp?.append(leave)
                staffsLeaves[leave.sid!] = tmp
            }
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
        guard let count = staffKeys()?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        let staffId = staffKeys()?[indexPath.row]
        let leaves = staffsLeaves[staffId!]
        let staff = getStaff(staffId: staffId!)
        cell.layoutCell(staff: staff!, leaves: leaves!)
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
                monthButton.setTitle("選擇月份", for: .normal)
                return
            }
            monthButton.setTitle(("\(text)"), for: .normal)
            let start = getStartAndEndTime(stringDate: text)[0]
            let end = getStartAndEndTime(stringDate: text)[1]
            self.getRangeLeaveList(start, end)
        }
    }
    
    //MARK: Getter
    private func staffKeys() -> [String]? {
        var allkeys: [String]? = []
        for keys in staffsLeaves.keys{
            allkeys?.append(keys)
        }
        return allkeys
    }
    
    private func getStaff(staffId: String) -> Staff? {
        for staff in stafflist!{
            if staffId == staff.sid { return staff }
        }
        return nil
    }
}
