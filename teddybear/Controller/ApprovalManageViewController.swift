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
    private var leaveList: [Leave]?
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    private var coworkerList: [Staff]? = StaffManager.sharedInstance().coworkerList()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "簽核管理"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbHUD.show()
        getStaffList()
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
        for approval in approvals {
            if (getLeave(approval.leaveId) != nil) {
                continue
            }
            LeaveManager.sharedInstance().getLeave(approval.leaveId, completion: { (leave, error) in
                self.leaveList?.append(leave!)
                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
        tbHUD.dismiss()
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = leaveList?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ApprovalCell.self) , for: indexPath) as! ApprovalCell
        let approval = approvalList?[indexPath.row]
        let leave = getLeave(approval?.leaveId)
        cell.layoutCell(with: approval, leave: leave)
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueApproval, sender: approvalList?[indexPath.row])
    }
    
    //MARK: Getter
    func getLeave(_ leaveId: String!) -> Leave? {
        var result = leaveList?.filter({ (leave) -> Bool in
            leave.leaveId == leaveId
        })
        return ((result?.isEmpty)! ? nil : result![0])
    }
}
