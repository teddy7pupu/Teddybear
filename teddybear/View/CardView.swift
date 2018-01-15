//
//  CardView.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/15.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class CardView: UIView {
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var deptLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.frame.height
    }
    
    public func layoutCardView() {
        //mock data
        avatarImg.image = UIImage(named: "pic_mb")
        nameLbl.text = "詹姆士"
        englishLbl.text = "James"
        mailLbl.text = "jxee@appmaster.cc"
        phoneLbl.text = "0988328343"
        deptLbl.text = "系統開發部"
        titleLbl.text = "經理"
    }
}
