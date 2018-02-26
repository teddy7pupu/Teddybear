//
//  ReportINTCell.swift
//  teddybear
//
//  Created by msp310 on 2018/2/24.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportITNCell: UITableViewCell {
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var signCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
        avatarImg.clipsToBounds = true
    }
    
    func layoutCell(staff: Staff, signCount: Int) {
        if let avatar = staff.avatar {
            avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
        } else {
            avatarImg.image = nil
        }
        nameLbl.text = staff.name
        signCountLbl.text = String(signCount)
    }
}
