//
//  StaffCell.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class StaffCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var mailLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
    }
    
    func layoutCell(with staff:Staff?) {
        nameLbl.text = staff?.name
        englishLbl.text = staff?.english
        mailLbl.text = staff?.email
    }
}
