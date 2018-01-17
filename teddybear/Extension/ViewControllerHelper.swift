//
//  ViewControllerHelper.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/17.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(message: String!) {
        tbHUD.dismiss()
        UIAlertController.alert(message: message).otherHandle(alertAction: nil).show(currentVC: self)
    }
}
