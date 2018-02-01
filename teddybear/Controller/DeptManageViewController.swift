//
//  DeptManageViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/17.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class DeptManageViewController: UIViewController
, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    
    var list: [Department]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "部門管理"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDeptList()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail, let dept = sender as? Department {
            let detailView = segue.destination as! DeptDetailViewController
            detailView.currentDepartment = dept
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Action
    func getDeptList() {
        tbHUD.show()
        StaffManager.sharedInstance().getDepartmentList { (list, error) in
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
        guard let count = list?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DeptCell.self), for: indexPath) as! DeptCell
        cell.layoutCell(with: list?[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         tableView.deselectRow(at: indexPath, animated: true)
        let dept = list?[indexPath.row]
        self.performSegue(withIdentifier: tbDefines.kSegueDetail, sender: dept)
    }
}
