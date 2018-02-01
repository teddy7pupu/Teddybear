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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "出勤報表"
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
            tbHUD.dismiss()
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
            self.list = list
            if list?.isEmpty != true { self.removeIsQuitStaff(list: list) }
            self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
    
    func removeIsQuitStaff(list: [Staff]?) {
        var count: Int = 0
        for staff in list!{
            if staff.isQuit == true {
                self.list?.remove(at: count)
            }
            else {
                count += 1
            }
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = list?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportCell.self) , for: indexPath) as! ReportCell
        cell.layoutCell(with:list?[indexPath.row])
        return cell
    }
}
