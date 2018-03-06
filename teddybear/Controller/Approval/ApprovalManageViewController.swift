//
//  ApprovalManageViewController.swift
//  teddybear
//
//  Created by msp310 on 2018/1/29.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ApprovalManageViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    
    private var approvalList: [Approval]?
    private var signedList: [Approval]?
    private var unsignedList: [Approval]?
    private var leaveList: [Leave]?
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    private var coworkerList: [Staff]? = StaffManager.sharedInstance().coworkerList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbHUD.show()
        getStaffList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets(tableView: mainTable)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueApproval {
            let detailView = segue.destination as! ApprovalDetailViewController
            let approval = sender as! Approval
            let leave = getLeave(approval.leaveId)
            detailView.currentApproval = approval
            detailView.currentLeave = leave
        }
    }
    
    //MARK: Action
    func getStaffList() {
        if coworkerList == nil {
            manager?.getStaffList(completion: { (list, error) in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }
                self.coworkerList = self.manager?.coworkerList()
                self.getStaffList()
            })
            return
        }
        getMyApprovals()
    }
    
    func getMyApprovals() {
        if let sid = currentStaff?.sid {
            ApprovalManager.sharedInstance().getApprovalList(sid, completion: { (list, error) in
                if let error = error {
                    NSLog(error.localizedDescription)
                    return
                }
                self.approvalList = list
                if (self.approvalList != nil) {
                    self.unsignedList = self.getApprovalList(isSigned: false)
                    self.signedList = self.getApprovalList(isSigned: true)
                    self.getMyApprovalLeaves(approvals: list!)
                }
            })
        }
    }
    
    func getMyApprovalLeaves(approvals: [Approval]) {
        leaveList?.removeAll()
        if (leaveList == nil) {
            leaveList = []
        }
        var tick = 0
        for approval in approvals {
            if (getLeave(approval.leaveId) != nil) {
                tick += 1
                continue
            }
            LeaveManager.sharedInstance().getLeave(approval.leaveId, completion: { (leave, error) in
                self.leaveList?.append(leave!)
                tick += 1
            })
        }
        
        DispatchQueue.global().async {
            while(tick < approvals.count) { sleep(1) }
            tbHUD.dismiss()
            DispatchQueue.main.async {
                self.mainTable.isHidden = self.approvalList?.count == 0
                self.mainTable.reloadData()
            }
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = (section == 0 ? unsignedList : signedList) else { return 0 }
        return list.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0 ? "   待簽核假單" : "   已簽核假單")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ApprovalCell.self) , for: indexPath) as! ApprovalCell
        let list = (indexPath.section == 0 ? unsignedList : signedList)
        let approval = list?[indexPath.row]
        let leave = getLeave(approval?.leaveId)
        cell.layoutCell(with: approval, leave: leave)
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let list = (indexPath.section == 0 ? unsignedList : signedList)
        performSegue(withIdentifier: tbDefines.kSegueApproval, sender: list?[indexPath.row])
    }
    
    //MARK: Getter
    func getLeave(_ leaveId: String!) -> Leave? {
        let result = leaveList?.filter({ (leave) -> Bool in
            leave.leaveId == leaveId
        })
        return (result?.isEmpty)! ? nil : result?[0]
    }
    
    func getApprovalList(isSigned: Bool) -> [Approval]? {
        return self.approvalList?.filter({ (approval) -> Bool in
            isSigned ? (approval.status != 0) : (approval.status == 0)
        })
    }
}
