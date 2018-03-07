//
//  SignDetailViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class SignDetailViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var pickerView: tbPickerView!
    @IBOutlet weak var dateField: UITextField!
    private var mlist: [Sign]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tbHUD.show()
        setupLayout()
        getCurrentList()
    }
    
    func setupLayout() {
        dateField.inputView = pickerView
        pickerView.type = .MonthYear
        pickerView.owner = dateField
        
        let current = Date().toString(format: .isoYearMonth)
        monthButton.setTitle("\(current) ▼", for: .normal)
        dateField.text = current
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(SignDetailViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    @IBAction func onSelectMonth() {
        dateField.becomeFirstResponder()
    }
    
    func getCurrentList() {
        let start = Date.startMonth(yearMonth: dateField.text!).timeIntervalSince1970
        let end = Date.endMonth(yearMonth: dateField.text!).timeIntervalSince1970
        getList(start: Int(start), end: Int(end))
    }
    
    func getList(start: Int, end: Int){
        SignManager.sharedInstance().getRangeSignList(start, end, completion: { (list, error) in
            if error != nil { return }
            self.mlist = (self.filterMyList(list: list).count != 0 ? self.filterMyList(list: list) : nil )
            self.mainTable.reloadData()
            tbHUD.dismiss()
        })
    }
    
    func filterMyList(list: [Sign]?) -> [Sign]{
        guard let sid = StaffManager.sharedInstance().currentStaff?.sid else {
            self.showAlert(message: "員工資料取得失敗")
            return []
        }
        var source: [Sign] = []
        for myList in list! {
            if myList.sid == sid { source.append(myList) }
        }
        return source
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
            getList(start: Int(start), end: Int(end))
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = mlist?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "InternReportDetailCell") , for: indexPath) as! ReportDetailCell
        if let source = mlist?[indexPath.row] {
            cell.layoutCell(with: source)
        }
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
