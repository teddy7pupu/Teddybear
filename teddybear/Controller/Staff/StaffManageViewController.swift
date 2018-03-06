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

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deptBtn: UIButton!
    @IBOutlet weak var mainTable: UITableView!
    private var list: [Staff]?
    private var isAccount: Bool {
        get {
            guard let staff = StaffManager.sharedInstance().currentStaff else { return true }
            return (staff.role?.isAccount())!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getStaffList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        fixTableViewInsets(tableView: mainTable)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail, let staff = sender as? Staff {
            let detailView = segue.destination as! StaffDetailViewController
            detailView.currentStaff = staff
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func setupLayout() {
        self.title = "通訊錄"
        if !isAccount {
            addBtn.isHidden = true
            deptBtn.isHidden = true
            mainTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: addBtn.bounds.height, right: 0)
        }
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
    
    func updateStaff(staff: Staff) {
        StaffManager.sharedInstance().updateStaff(staff) { (staff, error) in
            tbHUD.dismiss()
            if let error = error {
                NSLog("%@", error.localizedDescription)
                self.showAlert(message: "資料更新失敗")
                return
            }
            guard let name = staff?.name else { return }
            self.showAlert(message: "\(name)離職囉!")
            self.getStaffList()
        }
    }
    
    func quitStaff(staff: Staff) {
        tbHUD.show()
        var newStaff = staff
        newStaff.quitDate = Int(Date().timeIntervalSince1970)
        self.updateStaff(staff: newStaff)
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = list?.count else { return 0 }
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
        if isAccount {
            self.performSegue(withIdentifier: tbDefines.kSegueDetail, sender: staff)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let staff = list?[indexPath.row] else { return false }
        return !(staff.mobile?.isEmpty)!
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions: [UITableViewRowAction] = []
        let staff = list?[indexPath.row]
        if isAccount, staff?.quitDate == nil {
            let quitAction = UITableViewRowAction(style: .destructive, title: "離職") { (action, indexPath) in
                guard let name = staff?.name else { return }
                self.showAlert(message: "確定要讓\(name)離職嗎", completion: {
                    self.quitStaff(staff: staff!)
                })
            }
            actions.append(quitAction)
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
        dialAction.backgroundColor = UIColor.SPGreen
        actions.append(dialAction)
        return actions
    }
}
