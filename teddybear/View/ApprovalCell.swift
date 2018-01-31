//
//  ApprovalCell.swift
//  teddybear
//
//  Created by msp310 on 2018/1/29.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ApprovalCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var applyTimeLbl: UILabel!
    @IBOutlet weak var aTypeBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        aTypeBtn.layer.cornerRadius = 5
        aTypeBtn.layer.borderWidth = 1.5
        statusBtn.layer.cornerRadius = 5
    }

    func layoutCell(with approval:Approval?, leave:Leave?){
        guard let approval = approval, let leave = leave else { return }
        layoutHoursLabel(leave: leave)
        layoutATypeButton(approval: approval, leave: leave)
        layoutStatusButton(approval: approval)
        nameLbl.text = manager?.getStaff(byStaffId: leave.sid!)?.name
        typeLbl.text = leave.type
        applyTimeLbl.text = Date(timeIntervalSince1970: TimeInterval(leave.applyTime!))
            .toString(format: .custom("yyyy-MM-dd HH:mm:ss"))
    }
    
    func layoutCell(with approval:Approval?) {
        guard let approval = approval else { return }
        aTypeBtn.layer.borderColor = aTypeBtn.currentTitleColor.cgColor
        layoutStatusButton(approval: approval)
        nameLbl.text = manager?.getStaff(byStaffId: approval.sid!)?.name
        applyTimeLbl.text = (approval.time != nil) ? Date(timeIntervalSince1970: TimeInterval(approval.time!))
            .toString(format: .custom("yyyy-MM-dd HH:mm:ss")) : ""
        typeLbl.text = approval.message
    }
    
    private func layoutHoursLabel(leave: Leave) {
        let beginDate = Date(timeIntervalSince1970: TimeInterval((leave.startTime)!))
        let endDate = Date(timeIntervalSince1970: TimeInterval((leave.endTime)!))
        let hours = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
        hoursLbl.text = "\(hours/8) 天 \(hours%8) 小時"
    }
    
    private func layoutATypeButton(approval: Approval, leave: Leave) {
        guard let aid = leave.approvals?.first?.aid else {
            aTypeBtn.isHidden = true
            return
        }
        aTypeBtn.isHidden = false
        aTypeBtn.isSelected = (aid != approval.aid)
        aTypeBtn.layer.borderColor = aTypeBtn.currentTitleColor.cgColor
    }
    
    private func layoutStatusButton(approval: Approval) {
        switch approval.status {
        case 1?:
            statusBtn.isSelected = true
            statusBtn.isEnabled = true
            statusBtn.backgroundColor = UIColor(named: "SPGreen")
            break
        case 2?:
            statusBtn.isSelected = false
            statusBtn.isEnabled = false
            statusBtn.backgroundColor = UIColor.darkGray
            break
        default:
            statusBtn.isSelected = false
            statusBtn.isEnabled = true
            statusBtn.backgroundColor = UIColor.lightGray
        }
    }
}
