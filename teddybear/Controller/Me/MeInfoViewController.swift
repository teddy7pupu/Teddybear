//
//  MeInfoViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/3/7.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class MeInfoViewController: UITableViewController {

    var staff: Staff?
    
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var deptLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var onboardLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutStaff()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    internal func layoutStaff() {
        guard let staff = staff else { return }
        
        idLbl.text = staff.sid
        titleLbl.text = staff.title
        onboardLbl.text = Date(timeIntervalSince1970: Double(staff.onBoardDate!)).toString(format: .isoDate)
        let manager = StaffManager.sharedInstance()
        if manager.departmentList() == nil {
            tbHUD.show()
            manager.getDepartmentList(completion: { (list, error) in
                tbHUD.dismiss()
                let dept = manager.getDepartment(byID: staff.department!)
                DispatchQueue.main.async {
                    self.deptLbl.text = dept?.title
                }
            })
            return
        }
        deptLbl.text = manager.getDepartment(byID: staff.department!)?.title
    }
}
