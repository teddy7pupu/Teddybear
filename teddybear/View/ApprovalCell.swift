//
//  ApprovalCell.swift
//  teddybear
//
//  Created by msp310 on 2018/1/29.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ApprovalCell: UITableViewCell {

    @IBOutlet weak var applicant: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var applyTime: UILabel!
    private weak var manager: StaffManager? = StaffManager.sharedInstance()
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func layoutCell(with approval:Approval?, leave:Leave?){
        guard let sid = leave?.sid,
              let applicantStatus = approval?.status,
              let time = leave?.applyTime else { return }
        applicant.text = manager?.getStaff(byStaffId: sid)?.name
        status.text = tbDefines.kStatus[applicantStatus]
        applyTime.text = Date(timeIntervalSince1970: TimeInterval(time)).toString(format: .isoDate)
    }
}
