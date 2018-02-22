//
//  SignCell.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class SignCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var week: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func layoutCell(with sign: Sign?) {
        if let start = sign?.startTime {
            day.text = Date(timeIntervalSince1970: TimeInterval(start)).toString(format: .isoDate)
            week.text = Date(timeIntervalSince1970: TimeInterval(start)).toString(format: .isoDateWeek)
            startTime.text = Date(timeIntervalSince1970: TimeInterval(start)).toString(format: .isoTime)
        }
        if let end = sign?.endTime{
            endTime.text = Date(timeIntervalSince1970: TimeInterval(end)).toString(format: .isoTime)
        }
    }
}
