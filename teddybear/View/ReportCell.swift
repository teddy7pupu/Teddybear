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
    @IBOutlet weak var leaveLbl: UILabel!
    @IBOutlet weak var hourLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
        avatarImg.clipsToBounds = true
    }

    func layoutCell(staff: Staff, leavesCount: Int, total: String) {
        getImage(staff: staff)
        nameLbl.text = staff.name
        leaveCountLbl.text = String(leavesCount)
        hourTotalLbl.text = total
    }
    
    func layoutInternCell(staff: Staff, signCount: Int){
        getImage(staff: staff)
        nameLbl.text = staff.name
        leaveCountLbl.text = String(signCount)
        leaveLbl.text = "上班天數 : "
        hourLbl.isHidden = true
        hourTotalLbl.isHidden = true
    }
    
    func getImage(staff: Staff){
        if let avatar = staff.avatar {
            avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
        } else {
            avatarImg.image = nil
        }
    }
}
