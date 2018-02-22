//
//  StaffCell.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class StaffCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var quitLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
        avatarImg.clipsToBounds = true
    }
    
    func layoutCell(with staff:Staff?) {
        if let avatar = staff?.avatar {
            avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
        } else {
            avatarImg.image = nil
        }
        nameLbl.text = staff?.name
        englishLbl.text = staff?.english
        mailLbl.text = staff?.email
        quitLbl.isHidden = (staff?.isQuit == nil)
    }
}
