//
//  LeaveDetailViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/27.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class LeaveDetailViewController: UITableViewController
, UITextFieldDelegate {

    @IBOutlet weak var beginTimeLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var assigneeLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var summationLbl: UILabel!
    @IBOutlet weak var assigneeCell: ApprovalCell!
    @IBOutlet weak var managerCell: ApprovalCell!
    @IBOutlet weak var deleteBtn: UIButton?
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var coworkerList: [Staff]? = StaffManager.sharedInstance().coworkerList()
    var currentLeave: Leave?
    
    private var tableStatus: Int = 0    //0:Only section(0), 1:Section(1,0), 2:Section(1,1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentLeave?.type?.rawValue
        setupLayout()
        getStaffList { (error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
            }
            self.layoutLeave(leave: self.currentLeave)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    internal func setupLayout() {
    }
    
    internal func layoutLeave(leave: Leave?) {
        guard let leave = leave else { return }
        
        let beginDate = Date(timeIntervalSince1970: TimeInterval(leave.startTime!))
        let endDate = Date(timeIntervalSince1970: TimeInterval(leave.endTime!))
        beginTimeLbl.text = beginDate.toString(style: .short)
        endTimeLbl.text = endDate.toString(style: .short)
        typeLbl.text = leave.type?.rawValue
        assigneeLbl.text = manager?.getStaff(byStaffId: leave.assigneeId!)?.name
        messageLbl.text = leave.message
        let hour = Date.leaveHour(beginDate, endDate)
        summationLbl?.text = "總計: \(hour/8) 天  \(hour%8) 小時"
        
        let assignee = leave.approvals?.first
        if assignee == nil {
            self.tableView.isUserInteractionEnabled = false
            return
        }
        tableStatus = 1
        assigneeCell.layoutCell(with: assignee)
        if leave.leaveStatus() != 0 {
            deleteBtn?.isEnabled = false
            deleteBtn?.backgroundColor = UIColor.SPLight
        }
        
        guard (leave.approvals?.count)! > Int(1) else {
            self.tableView.reloadData()
            return
        }
        tableStatus = 2
        let supervisor = leave.approvals![1]
        managerCell.layoutCell(with: supervisor)
        if leave.leaveStatus() != 0 {
            deleteBtn?.setTitle("假單已簽核", for: .disabled)
        }
        self.tableView.reloadData()
    }
    
    //MARK: Action
    internal func getStaffList(completion:@escaping (Error?) -> Void) {
        if coworkerList == nil {
            manager?.getStaffList(completion: { (list, error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.coworkerList = self.manager?.coworkerList()
                completion(nil)
            })
        } else {
            completion(nil)
        }
    }
    
    internal func deleteLeave() {
        let leave = currentLeave
        LeaveManager.sharedInstance().removeLeaveData(leave) { (error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.showAlert(message: "假單已經刪除囉!", completion: {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
    }
    
    @IBAction func onDeleteLeave() {
        self.showAlert(message: "確定要刪除假單嗎？") {
            self.deleteLeave()
        }
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (tableStatus > 0) ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 6
        }
        return tableStatus
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView .deselectRow(at: indexPath, animated: true)
    }
}
