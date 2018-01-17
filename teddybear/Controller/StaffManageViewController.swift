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
        tbHUD.show()
        StaffManager.sharedInstance().getStaffList { (list, error) in
            tbHUD.dismiss()
            if let error = error {
                NSLog(error.localizedDescription)
                return
            }
            self.list = list
            self.mainTable.reloadData()
        }
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
}
