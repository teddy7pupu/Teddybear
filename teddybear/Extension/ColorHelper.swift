//
//  ColorHelper.swift
//  teddybear
//
//  Created by JLee21 on 2018/2/27.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
    
    open class var SPBlack: UIColor {
        get {
            return UIColor(hex: 0x121212)
        }
    }
    
    open class var SPDark: UIColor {
        get {
            return UIColor(hex: 0x212121)
        }
    }
    
    open class var SPGray: UIColor {
        get {
            return UIColor(hex: 0x535353)
        }
    }
    
    open class var SPGreen: UIColor {
        get {
            return UIColor(hex: 0x1DB954)
        }
    }
    
    open class var SPLight: UIColor {
        get {
            return UIColor(hex: 0xB3B3B3)
        }
    }
    
    func image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
