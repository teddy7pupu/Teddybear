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
    
    @IBOutlet weak var checkInBtn: UIButton!
    @IBOutlet weak var checkOutBtn: UIButton!
    @IBOutlet weak var checkInLbl: UILabel!
    @IBOutlet weak var checkOutLbl: UILabel!
    
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
        layoutReport(time: sign?.startTime, button: checkInBtn, label: checkInLbl)
        layoutReport(time: sign?.endTime, button: checkOutBtn, label: checkOutLbl)
    }
    
    internal func layoutReport(time: Int?, button: UIButton!, label: UILabel!) {
        let time = time
        button.isSelected = (time == nil)
        button.backgroundColor = (time == nil) ? UIColor.red : UIColor.SPGreen
        if time != nil {
            let date = Date(timeIntervalSince1970: Double(time!))
            label.text = "\(date.toString(style: DateStyleType.short)) \(date.toString(style: DateStyleType.shortWeekday))"
        } else {
            label.text = ""
        }
    }
}
