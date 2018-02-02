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
    private var list: [Staff]? = []
    private var staffLeaveList: [[Leave]]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "假勤報表"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStaffList()
    }
    
    //MARK: Action
    func getStaffList() {
        tbHUD.show()
        StaffManager.sharedInstance().getStaffList { (list, error) in
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
            self.list = list
            self.getStaffLeaves(staffList: list)
        }
    }
    
    func getStaffLeaves(staffList: [Staff]?) {
        var count: Int = 0
        for staff in staffList!{
            LeaveManager.sharedInstance().getLeaveList(staff.sid, completion: { (list, error) in
                tbHUD.dismiss()
                if list?.count == 0 {
                    self.list?.remove(at: count)
                }
                else {
                    self.staffLeaveList?.append(list!)
                    count += 1
                }
                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = list?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        if (self.staffLeaveList?.count)! - 1 >= indexPath.row {
            cell.layoutCell(with: list?[indexPath.row], leaves: self.staffLeaveList?[indexPath.row])
        }
        return cell
    }
}

