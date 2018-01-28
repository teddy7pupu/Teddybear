//
//  ApprovalManageViewController.swift
//  teddybear
//
//  Created by msp310 on 2018/1/29.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ApprovalManageViewController: UIViewController {
    
    private var approvalList: [Approval]?
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMyApprovals()
    }
    
    //MARK: Action
    func getMyApprovals() {
        tbHUD.show()
        if let sid = currentStaff?.sid {
            ApprovalManager.sharedInstance().getApprovalList(sid, completion: { (list, error) in
                tbHUD.dismiss()
                if let error = error {
                    NSLog(error.localizedDescription)
                    return
                }
                self.approvalList = list
                print(self.approvalList?.count as Any)
            })
        }
    }
}
