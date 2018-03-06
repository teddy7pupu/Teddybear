//
//  ReportDetailCell.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/2.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportDetailCell: UITableViewCell {
    
    @IBOutlet weak var startDateView: tbCalendarView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var hoursLbl: UILabel!
    @IBOutlet weak var reasonLbl: UILabel!
    
    @IBOutlet weak var clockInLbl: UILabel!
    @IBOutlet weak var clockOutLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func layoutCell(with leave: Leave) {
        startDateView.layoutView(date: Date(timeIntervalSince1970: Double(leave.startTime!)))
        typeLbl.text = leave.type?.rawValue
        reasonLbl.text = "事由：" + leave.message!
        
        let beginDate = Date(timeIntervalSince1970: TimeInterval(leave.startTime!))
        let endDate = Date(timeIntervalSince1970: TimeInterval(leave.endTime!))
        let hour = Date.leaveHour(beginDate, endDate)
        hoursLbl.text = hour > 8 ? String(format:"%.1f天", Double(hour)/8) : "\(hour)小時"
    }
    
    func layoutCell(with sign: Sign?) {
        guard let time = (sign?.startTime != nil) ? sign?.startTime : sign?.endTime else { return }
        let date = Date(timeIntervalSince1970: Double(time))
        
        startDateView.layoutView(date: date)
        typeLbl.text = date.toString(style: .shortWeekday)
        layoutClockLbl(label: clockInLbl, time: sign?.startTime)
        layoutClockLbl(label: clockOutLbl, time: sign?.endTime)
        
        reasonLbl.isHidden = !(!date.compare(.isToday) && (sign?.startTime == nil || sign?.endTime == nil))
    }
    
    internal func layoutClockLbl(label: UILabel!, time: Int?) {
        guard let time = time else {
            label.text = "---"
            return
        }
        let date = Date(timeIntervalSince1970: Double(time))
        label.text = date.toString(format: .isoTime)
    }
}
