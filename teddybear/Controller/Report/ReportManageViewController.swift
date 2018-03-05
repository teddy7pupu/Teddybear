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
    @IBOutlet weak var typeCtrl: UISegmentedControl!
    
    private weak var manager = StaffManager.sharedInstance()
    private var staffsLeaves: Dictionary<String, [Leave]>?
    private var staffsLeaveHours: Dictionary<String, String>?
    private var internsSign: Dictionary<String, [Sign]>?
    
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
        if segue.identifier != tbDefines.kSegueReport {
            return
        }
        let detailView = segue.destination as! ReportDetailViewController
        if typeCtrl.selectedSegmentIndex == 0 {
            
            let staffId = sender as? String
            guard let leaves = staffsLeaves?[staffId!]
                ,let staff = manager?.getStaff(byStaffId: staffId!) else {
                    return
            }
            detailView.name = staff.name
            detailView.staffLeaves = leaves
            return
        }
        
        let internId = sender as? String
        guard let signs = internsSign?[internId!]
            , let intern = manager?.getStaff(byStaffId: internId!) else {
                return
        }
        detailView.name = intern.name
        detailView.internSigns = signs
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        typeCtrl.selectedSegmentIndex = 0
        
        dateField.inputView = pickerView
        pickerView.type = .MonthYear
        pickerView.owner = dateField
        
        let current = Date().toString(format: .isoYearMonth)
        monthButton.setTitle("\(current) ▼", for: .normal)
        dateField.text = current
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ReportManageViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    //MARK: Action
    func csvFileOut(path: URL?){
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
        let output = (typeCtrl.selectedSegmentIndex == 0 ? leaveReport() : internReport())
        do {
            try output.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            showAlert(message: "Failed to create file")
        }
        tbHUD.dismiss()
    }
    
    func leaveReport() -> String{
        var csvText = "姓名,假別,開始時間,結束時間,小計,總計\n"
        for (staffSid, leaves) in staffsLeaves! {
            if let staffName = manager?.getStaff(byStaffId: staffSid)?.name{
                csvText.append("\(staffName)")
            }
            var totalHour = 0
            for leave in leaves {
                let type = leave.type!
                let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
                let endDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
                let hour = Date.leaveHour(beginDate, endDate)
                totalHour += hour
                let startDay = beginDate.toString(format: .custom("dd"))
                let startMonth = beginDate.toString(format: .custom("MM"))
                let startTime = beginDate.toString(format: .isoTime)
                let endDay = endDate.toString(format: .custom("dd"))
                let endMonth = endDate.toString(format: .custom("MM"))
                let endTime = endDate.toString(format: .isoTime)
                csvText.append(",\(type),\(startMonth)月\(startDay)日\(startTime),\(endMonth)月\(endDay)日\(endTime),\(hour)小時\n")}
            csvText.append(",,,,,總共\(totalHour)小時\n")
        }
        return csvText
    }
    
    func internReport() -> String{
        var csvText = "姓名,日期,上班時間,下班時間,總天數\n"
        for (internSid, signs) in internsSign! {
            var count: Int = 0
            if let internName = manager?.getStaff(byStaffId: internSid)?.name{
                csvText.append("\(internName)")
            }
            for sign in signs {
                let time = Date(timeIntervalSince1970: TimeInterval(sign.startTime!)).toString(format: .isoDate)
                let beginDate = Date(timeIntervalSince1970: TimeInterval(sign.startTime!)).toString(format: .isoTime)
                var finishDate = ""
                if sign.endTime != nil{
                    finishDate = Date(timeIntervalSince1970: TimeInterval(sign.endTime!)).toString(format: .isoTime)
                    count += 1
                }
                csvText.append(",\(time),\(beginDate),\(finishDate)\n")
            }
            csvText.append(",,,,總共\(count)天\n")
        }
        return csvText
    }
    
    @IBAction func onChange(_ sender: Any) {
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @IBAction func onOutput(_ sender: Any) {
        if let time = dateField.text {
            tbHUD.show()
            if typeCtrl.selectedSegmentIndex == 0 {
                let fileName = "\(time)假勤報表.csv"
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                csvFileOut(path: path)
            } else {
                let fileName = "\(time)實習生簽到表.csv"
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                csvFileOut(path: path)
            }
            
        }
    }
    
    func getMonthList() {
        let start = Date.startMonth(yearMonth: dateField.text!).timeIntervalSince1970
        let end = Date.endMonth(yearMonth: dateField.text!).timeIntervalSince1970
        self.getRangeLeaveList(Int(start), Int(end))
        self.getInternSignList(Int(start), Int(end))
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
        })
    }
    
    func getInternSignList(_ start: Int, _ end: Int){
        SignManager.sharedInstance().getRangeSignList(start, end, completion: { (list, error) in
            if error != nil { return }
            self.mappingIntern(internSigns: list)
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
        self.mapping(passLeaveList: list)
    }
    
    //假單和員工分類成字典
    func mapping(passLeaveList: [Leave]?){
        staffsLeaves = [:]
        staffsLeaveHours = [:]
        for leave in passLeaveList! {
            if staffsLeaves?[leave.sid!] == nil {
                staffsLeaves?[leave.sid!] = [leave]
            } else {
                var tmp: [Leave] = staffsLeaves![leave.sid!]!
                tmp.append(leave)
                staffsLeaves?[leave.sid!] = tmp
            }
        }
        for staffId in staffKeys()!{
            staffsLeaveHours?[staffId] = getTotalHours(leaves: staffsLeaves?[staffId]!)
        }
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        tbHUD.dismiss()
    }
    
    func mappingIntern(internSigns: [Sign]?){
        internsSign = [:]
        for sign in internSigns!{
            if internsSign?[sign.sid!] == nil {
                internsSign?[sign.sid!] = [sign]
            } else {
                var tmp: [Sign] = internsSign![sign.sid!]!
                tmp.append(sign)
                internsSign?[sign.sid!] = tmp
            }
        }
        self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    func getTotalHours(leaves: [Leave]?) -> String {
        var summation: Int = 0
        for leave in leaves! {
            let beginDate = Date(timeIntervalSince1970: TimeInterval(leave.startTime!))
            let endDate = Date(timeIntervalSince1970: TimeInterval(leave.endTime!))
            let hour = Date.leaveHour(beginDate, endDate)
            summation += hour
        }
        return summation > 8 ? String(format:"%.1f天", Double(summation)/8) : "\(summation)小時"
    }
    
    @IBAction func onSelectMonth() {
        dateField.becomeFirstResponder()
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if typeCtrl.selectedSegmentIndex == 0 {
            guard let staffCount = staffKeys()?.count else { return 0 }
            return staffCount
        }
        guard let internCount = internKeys()?.count else { return 0 }
        return internCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if typeCtrl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
            let staffId = staffKeys()?[indexPath.row]
            let leaves = staffsLeaves?[staffId!]
            let staff = manager?.getStaff(byStaffId: staffId!)
            let total = staffsLeaveHours?[staffId!]
            cell.layoutCell(staff: staff!, leavesCount: (leaves!.count), total: total!)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "InternReportCell") , for: indexPath) as! ReportCell
        let internId = internKeys()?[indexPath.row]
        let signs = internsSign?[internId!]
        var effectSign = 0
        for sign in signs! {
            if sign.endTime != nil { effectSign += 1 }
        }
        let intern = manager?.getStaff(byStaffId: internId!)
        cell.layoutCell(staff: intern!, signCount: effectSign)
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if typeCtrl.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: tbDefines.kSegueReport, sender: staffKeys()?[indexPath.row])
        } else {
            performSegue(withIdentifier: tbDefines.kSegueReport, sender: internKeys()?[indexPath.row])
        }
    }
    
    // MARK: UITextFieldDelegate
    @IBAction func textFieldDidChanged(field: UITextField) {
        if field == dateField {
            guard let text = field.text, !text.isEmpty else {
                return
            }
            tbHUD.show()
            let startDate = Date.startMonth(yearMonth: text)
            let title = startDate.toString(format: .isoYearMonth)
            dateField.text = title
            monthButton.setTitle(("\(title) ▼"), for: .normal)
            let start = startDate.timeIntervalSince1970
            let end = Date.endMonth(yearMonth: text).timeIntervalSince1970
            self.getRangeLeaveList(Int(start), Int(end))
            self.getInternSignList(Int(start), Int(end))
        }
    }
    
    //MARK: Getter
    private func staffKeys() -> [String]? {
        guard let staffsLeaves = staffsLeaves else { return nil }
        return Array(staffsLeaves.keys)
    }
    
    private func internKeys() -> [String]? {
        guard let internsSign = internsSign else { return nil }
        return Array(internsSign.keys)
    }
}

