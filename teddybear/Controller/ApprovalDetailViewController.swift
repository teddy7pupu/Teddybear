//
//  ApprovalDetailViewController.swift
//  teddybear
//
//  Created by msp310 on 2018/1/29.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ApprovalDetailViewController: UITableViewController {
    
    @IBOutlet weak var beginTimeLbl: UILabel!     //開始時間
    @IBOutlet weak var beginPeriodLbl: UILabel!   //時段
    @IBOutlet weak var endTimeLbl: UILabel!       //結束時間、時段
    @IBOutlet weak var endPeriodLbl: UILabel!     //時段
    @IBOutlet weak var hoursLbl: UILabel!         //時數
    @IBOutlet weak var typeLbl: UILabel!          //假別
    @IBOutlet weak var messageLbl: UILabel!       //事由
    @IBOutlet weak var approvalMessageField: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!


    var currentApproval: Approval?
    var currentLeave: Leave?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutApproval()
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(LeaveDetailViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
    }
    
    func layoutApproval() {
        guard let leave = currentLeave,
            let approval = currentApproval else { return }
        
        let beginDate = Date(timeIntervalSince1970: TimeInterval(leave.startTime!))
        let endDate = Date(timeIntervalSince1970: TimeInterval(leave.endTime!))
        let hour = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
        
        beginTimeLbl.text = beginDate.toString(format: .isoDate)
        beginPeriodLbl.text = tbDefines.kBeginSection[leave.startPeriod!]
        endTimeLbl.text = endDate.toString(format: .isoDate)
        endPeriodLbl.text = tbDefines.kEndSection[leave.endPeriod!]
        hoursLbl.text = "\(hour/8) 天 \(hour%8) 小時"
        typeLbl.text = leave.type
        messageLbl.text = leave.message
        approvalMessageField.text = approval.message
        
        statusLbl.isHidden = (approval.status == 0)
    }
    
    //MARK: Action
    @IBAction func onAgree() {
        guard var approval = currentApproval else { return }
        
        tbHUD.show()
        approval.status = 1
        approval.message = approvalMessageField.text
        updateApproval(approval: approval)
    }
    
    @IBAction func onReject() {
        guard var approval = currentApproval else { return }
        
        tbHUD.show()
        approval.status = 2
        approval.message = approvalMessageField.text
        updateApproval(approval: approval)
    }
    
    func updateApproval(approval: Approval) {
        ApprovalManager.sharedInstance().updateApprovalData(approval) { (approval, error) in
            tbHUD.dismiss()
            if let error = error {
                NSLog("%@", error.localizedDescription)
                self.showAlert(message: "資料更新失敗")
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func keyboardDismiss(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
