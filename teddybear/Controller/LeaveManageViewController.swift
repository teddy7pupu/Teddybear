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
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
            })
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = leaveList?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LeaveCell.self) , for: indexPath) as! LeaveCell
        cell.layoutCell(with: leaveList?[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: tbDefines.kSegueDetail, sender: leaveList?[indexPath.row])
    }
}
