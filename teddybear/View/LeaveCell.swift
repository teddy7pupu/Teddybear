//
//  LeaveCell.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/27.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class LeaveCell: UITableViewCell {

    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func layoutCell(with leave:Leave?) {
        let beginDate = Date(timeIntervalSince1970: TimeInterval((leave?.startTime)!))
        let endDate = Date(timeIntervalSince1970: TimeInterval((leave?.endTime)!))
        monthLbl.text = beginDate.toString(style: .shortMonth)
        dayLbl.text = String(format:"%02d", beginDate.component(.day)!)
        typeLbl.text = leave?.type
        let duration = Date.leaveHour(beginDate, (leave?.startPeriod)!, endDate, (leave?.endPeriod)!)
        durationLbl.text = duration > 8 ? String(format:"%.1f天", Double(duration)/8) : "\(duration)小時"
        layoutStatusButton(leave: leave)
    }
    
    private func layoutStatusButton(leave: Leave!) {
        let status = leave.leaveStatus()
        switch status {
        case 1:
            statusBtn.isSelected = true
            statusBtn.isEnabled = true
            statusBtn.backgroundColor = UIColor.SPGreen
            break
        case 2:
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
