//
//  ReportDetailCell.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/2.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportDetailCell: UITableViewCell {

    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var startDayLbl: UILabel!
    @IBOutlet weak var startMonthLbl: UILabel!
    @IBOutlet weak var startPeriodLbl: UILabel!
    @IBOutlet weak var endDayLbl: UILabel!
    @IBOutlet weak var endMonthLbl: UILabel!
    @IBOutlet weak var endPeriodLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func layoutCell(with leave: Leave) {
        let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
        let endDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
        let hour = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
        startDayLbl.text = String(format:"%02d", beginDate.component(.day)!)
        startMonthLbl.text = beginDate.toString(style: .shortMonth)
        startPeriodLbl.text = tbDefines.kBeginSection[leave.startPeriod!]
        endDayLbl.text = String(format:"%02d", endDate.component(.day)!)
        endMonthLbl.text = endDate.toString(style: .shortMonth)
        endPeriodLbl.text = tbDefines.kEndSection[leave.endPeriod!]
        typeLbl.text = "\(leave.type!) :"
        totalLbl.text = hour > 8 ? String(format:"%.1f天", Double(hour)/8) : "\(hour)小時"
    }
}
