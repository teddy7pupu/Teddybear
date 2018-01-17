//
//  DeptCell.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/17.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class DeptCell: UITableViewCell {
    
    @IBOutlet weak var titleLBl: UILabel!
    @IBOutlet weak var supervisorLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func layoutCell(with dept: Department?) {
        titleLBl.text = dept?.title
        supervisorLbl.text = dept?.supervisor
    }
}
