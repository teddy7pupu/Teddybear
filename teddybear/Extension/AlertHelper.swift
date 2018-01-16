//
//  AlertHelper.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/17.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

typealias AlertActionType = (UIAlertAction?) -> ()
extension UIAlertController {
    
    class func alert(title: String? = "提示", message: String?) -> UIAlertController  {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        return alertController
    }
    
    func cancelHandle(title: String? = "取消", style: UIAlertActionStyle? = .cancel, alertAction: AlertActionType?) -> UIAlertController {
        
        let alert = UIAlertAction(title: title, style: style!) { (action) in
            if alertAction != nil{
                alertAction!(action)
            }
        }
        self.addAction(alert)
        return self
    }
    
    func otherHandle(title: String? = "確定", style: UIAlertActionStyle? = .default, alertAction: AlertActionType?) -> UIAlertController {
        let alert = UIAlertAction(title: title, style: style!) { (action) in
            if alertAction != nil{
                alertAction!(action)
            }
        }
        self.addAction(alert)
        return self
    }
    
    func show(currentVC: UIViewController)  {
        
        currentVC.present(self, animated: true, completion: nil)
    }
}
