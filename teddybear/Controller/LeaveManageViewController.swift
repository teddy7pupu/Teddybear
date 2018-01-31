//
//  LeaveManageViewController.swift
//  teddybear
//
//  Created by Teddy on 2018/1/19.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//
import UIKit

class LeaveManageViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    private var leaveList: [Leave]?
    private var signedList: [Leave]?
    private var unsignedList: [Leave]?
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "假單管理"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyLeaves()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail, let leave = sender as? Leave {
            let detailView = segue.destination as! LeaveDetailViewController
            detailView.currentLeave = leave
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Action
    func getMyLeaves() {
        tbHUD.show()
        if let sid = currentStaff?.sid {
            LeaveManager.sharedInstance().getLeaveList(sid, completion: { (list, error) in
                tbHUD.dismiss()
                if let error = error {
                    NSLog(error.localizedDescription)
                    return
                }
                self.leaveList = list
                self.unsignedList = self.getLeaveList(isSigned: false)
                self.signedList = self.getLeaveList(isSigned: true)
                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
    }
    
    func deleteLeave(leave: Leave, indexPath: IndexPath) {
        LeaveManager.sharedInstance().removeLeaveData(leave) { (error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.mainTable.beginUpdates()
            self.unsignedList?.remove(at: indexPath.row)
            self.mainTable.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            self.mainTable.endUpdates()
            self.showAlert(message: "假單已經刪除囉!")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LeaveCell.self) , for: indexPath) as! LeaveCell
        let list = (indexPath.section == 0 ? unsignedList : signedList)
        cell.layoutCell(with: list?[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        let list = (indexPath.section == 0 ? unsignedList : signedList)
        performSegue(withIdentifier: tbDefines.kSegueDetail, sender: list?[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard indexPath.section == 0 else { return false }
        let leave = unsignedList![indexPath.row]
        return leave.approvals?.first?.status == 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard indexPath.section == 0 else { return nil }
        let leave = unsignedList![indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "撤單") { (action, indexPath) in
            self.showAlert(message: "確定要刪除假單媽？", completion: {
                self.deleteLeave(leave: leave, indexPath: indexPath)
            })
        }
        return [deleteAction]
    }
    
    //MARK: Getter
    func getLeaveList(isSigned: Bool) -> [Leave]? {
        return leaveList?.filter({ (leave) -> Bool in
            isSigned ? leave.leaveStatus() != 0 : leave.leaveStatus() == 0;
        })
    }
}
