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
    
    private var approvalList: [Approval]? = []
    private var leaveList: [Leave]? = []
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    private var coworkerList: [Staff]? = StaffManager.sharedInstance().coworkerList()
    @IBOutlet weak var mainTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbHUD.show()
        getStaffList { (error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
            }
            self.getMyApprovals()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueApproval {
            let detailView = segue.destination as! ApprovalDetailViewController
            detailView.currentApproval = (sender as? [Any])
        }
    }
    
    //MARK: Action
    func getMyApprovals() {
        if let sid = currentStaff?.sid {
            ApprovalManager.sharedInstance().getApprovalList(sid, completion: { (list, error) in
                if let error = error {
                    NSLog(error.localizedDescription)
                    return
                }
                self.approvalList = list
                if list != nil { self.getMyApprovalLeaves(approvals: list!) }
            })
        }
    }
    
    func getMyApprovalLeaves(approvals: [Approval]) {
        for count in 0...(approvals.count - 1) {
            LeaveManager.sharedInstance().getApprovalLeave(approvals[count].leaveId, completion: { (leave, error) in
                self.leaveList?.append(leave!)
                self.mainTable.reloadData()
//                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
        tbHUD.dismiss()
    }
    
    func getStaffList(completion:@escaping (Error?) -> Void) {
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
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = leaveList?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ApprovalCell.self) , for: indexPath) as! ApprovalCell
            cell.layoutCell(with: approvalList?[indexPath.row], leave: leaveList?[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueApproval, sender: [approvalList?[indexPath.row] as Any, leaveList?[indexPath.row] as Any])
        leaveList = []
    }
}
