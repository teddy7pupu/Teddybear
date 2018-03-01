//
//  tbCalendarView.swift
//  teddybear
//
//  Created by JLee21 on 2018/3/1.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class tbCalendarView: UIView {
    
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var dayLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }
    
    func layoutView(date: Date!) {
        monthLbl.text = date.toString(style: DateStyleType.month)
        dayLbl.text = date.toString(format: DateFormatType.custom("dd"))
    }
}
