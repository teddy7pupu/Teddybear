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
    @IBOutlet weak var typeLbl: UILabel!          //假別
    @IBOutlet weak var messageLbl: UILabel!       //事由
    @IBOutlet weak var ApprovalMessageField: UITextField!
    @IBOutlet weak var agreeBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!


    var currentApproval: [Any]? // 0: 簽核 1:假單
    
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
    
    @IBAction func onAgree() {
        guard let approval: Approval = currentApproval![0] as? Approval else { return }
        tbHUD.show()
        var newApproval: Approval = approval
        newApproval.status = 1
        if safeString(source: ApprovalMessageField.text) != nil {
            newApproval.message = [safeString(source: ApprovalMessageField.text)!]
        }
        updateApproval(approval: newApproval)
    }
    
    @IBAction func onReject() {
        guard let approval: Approval = currentApproval![0] as? Approval else { return }
        tbHUD.show()
        var newApproval: Approval = approval
        newApproval.status = 2
        if safeString(source: ApprovalMessageField.text) != nil {
            newApproval.message = [safeString(source: ApprovalMessageField.text)!]
        }
        updateApproval(approval: newApproval)
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
    
    func layoutApproval() {
        guard let leave: Leave = currentApproval![1] as? Leave,
              let approval: Approval = currentApproval![0] as? Approval else { return }
        beginTimeLbl.text = Date(timeIntervalSince1970: TimeInterval(leave.startTime!)).toString(format: .isoDate)
        beginPeriodLbl.text = tbDefines.kBeginSection[leave.startPeriod!]
        endTimeLbl.text = Date(timeIntervalSince1970: TimeInterval(leave.endTime!)).toString(format: .isoDate)
        endPeriodLbl.text = tbDefines.kEndSection[leave.endPeriod!]
        typeLbl.text = leave.type
        messageLbl.text = leave.message
        if approval.message?.isEmpty == false {
            ApprovalMessageField.text = approval.message?[0]
        }
        if approval.status != 0 {
            agreeBtn.isEnabled = false
            rejectBtn.isEnabled = false
        }
        else {
            agreeBtn.isEnabled = true
            rejectBtn.isEnabled = true
        }
    }
    
    func safeString(source: String?) -> String? {
        if source?.count == 0 {
            return nil
        } else {
            return source
        }
    }
    
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
