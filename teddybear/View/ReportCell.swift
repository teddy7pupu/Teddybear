//
//  ReportCell.swift
//  teddybear
//
//  Created by msp310 on 2018/2/1.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var leaveCountLbl: UILabel!
    @IBOutlet weak var hourTotalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
        avatarImg.clipsToBounds = true
    }

    func layoutCell(staff: Staff, leaves: [Leave]?) {
        if let avatar = staff.avatar {
            avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
        } else {
            avatarImg.image = nil
        }
        nameLbl.text = staff.name
        leaveCountLbl.text = String(leaves!.count)
        hourTotalLbl.text = String(calculateHours(leaves: leaves))
    }
    
    func calculateHours(leaves: [Leave]?) -> String {
        var summation: Int = 0
        for leave in leaves! {
            let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
            let endDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
            let hour = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
            summation += hour
        }
        return summation > 8 ? String(format:"%.1f天", Double(summation)/8) : "\(summation)小時"
    }
}
