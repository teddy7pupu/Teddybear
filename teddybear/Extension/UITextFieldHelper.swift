//
//  UITextFieldHelper.swift
//  teddybear
//
//  Created by Samantha on 2018/1/23.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

extension UITextField {
    
    func isStringCountValid(text: String) -> Bool{
        if (text.count < 2 || text.count > 32){
            return false
        }
        return true
    }
    
    func isDateValid(text: String) -> Bool{
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard dateFormatter.date(from: text) != nil else{ return false }
        return true
    }
    
    func isEmailValid(text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with:text)
        return result
    }
    
    func isPhoneValid(text: String) -> Bool {
        let phoneRegEx = "^0[0-9]{3}[-]?[0-9]{3}[-]?[0-9]{3}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with:text)
        return result
    }
    
    
    func isSidValid(text: String) -> Bool {
        guard Int(text) == nil else { return true }
            
        let sidRegEx = "[A-Za-z][0-9]{3}"
        let sidTest = NSPredicate(format:"SELF MATCHES %@", sidRegEx)
        let result = sidTest.evaluate(with:text)
        return result
    }
    
    func isKeyValid(text: String) -> Bool {
        let keyRegEx = "[A-Z]{4}"
        let keyTest = NSPredicate(format:"SELF MATCHES %@", keyRegEx)
        let result = keyTest.evaluate(with:text)
        return result
    }
    
    

}
