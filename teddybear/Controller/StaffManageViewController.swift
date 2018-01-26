//
//  StaffManageViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/15.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class StaffManageViewController: UIViewController
    ,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var mainTable: UITableView!
    private var list: [Staff]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "員工管理"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStaffList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail {
            if let staff = sender as? Staff {
                let detailView = segue.destination as! StaffDetailViewController
                detailView.currentStaff = staff
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            self.mainTable.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = list?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StaffCell.self) , for: indexPath) as! StaffCell
        cell.layoutCell(with:list?[indexPath.row])
        return cell
    }
    
    //MARK UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let staff = list?[indexPath.row]
        self.performSegue(withIdentifier: tbDefines.kSegueDetail, sender: staff)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let staff = list?[indexPath.row] else { return false }
        return !(staff.mobile?.isEmpty)!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let staff = list?[indexPath.row]
        let quitAction = UITableViewRowAction(style: .destructive, title: "離職") { (action, indexPath) in
            //
        }
        if (staff?.mobile?.isEmpty)! {
            return [quitAction]
        }
        
        let dialAction = UITableViewRowAction(style: .normal, title: "通話") { (action, indexPath) in
            if let url = URL(string: "tel://" + (staff?.mobile)!), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        dialAction.backgroundColor = UIColor(named:"SPGreen")
        return [quitAction, dialAction]
    }
}
