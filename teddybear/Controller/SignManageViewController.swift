//
//  SignManageViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class SignManageViewController: UITableViewController {
    
    
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    private var todaySign: Sign?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Date().toString(format: .isoDate)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbHUD.show()
        checkWifi()
    }
    
    //MARK: Active
    @IBAction func onSignOut(_ sender: Any) {
        self.showAlert(message: "要\((signOutBtn.titleLabel?.text)!)嗎", completion: {
            tbHUD.show()
            self.reviseSign(startTime: nil, endTime: Int(Date().timeIntervalSince1970))
        })
        
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        self.showAlert(message: "要\((signInBtn.titleLabel?.text)!)嗎", completion: {
            tbHUD.show()
            self.reviseSign(startTime: Int(Date().timeIntervalSince1970) , endTime: nil)
        })
    }
    
    func updateSign(sign: Sign) {
        SignManager.sharedInstance().updateSignData(sign) { (sign, error) in
            tbHUD.dismiss()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func reviseSign(startTime: Int?, endTime: Int?){
        var newSign: Sign?
        if todaySign != nil {
            newSign = todaySign
        } else {
            newSign = Sign(signId: SignManager.sharedInstance().getAutoKey()!)
            newSign?.sid = StaffManager.sharedInstance().currentStaff?.sid
        }
        if startTime != nil && endTime == nil { newSign?.startTime = startTime }
        if startTime == nil && endTime != nil { newSign?.endTime = endTime }
        updateSign(sign: newSign!)
    }
    
    func btnSwitch(){
        if self.todaySign?.startTime == nil && self.todaySign?.endTime == nil {
            signInBtn.isEnabled = true
            signOutBtn.isEnabled = false
        }
        if self.todaySign?.startTime != nil && self.todaySign?.endTime == nil {
            signInBtn.isEnabled = false
            signOutBtn.isEnabled = true
        }
        if let startTitle = self.todaySign?.startTime {
            let title = Date(timeIntervalSince1970: TimeInterval(startTitle)).toString(format: .isoTime)
            signInBtn.setTitle("已完成簽到\(title)", for: .normal)
        }
        if let endTitle = self.todaySign?.endTime {
            let title = Date(timeIntervalSince1970: TimeInterval(endTitle)).toString(format: .isoTime)
            signOutBtn.setTitle("已完成簽退\(title)", for: .normal)
        }
        signInBtn.backgroundColor = signInBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
        signOutBtn.backgroundColor = signOutBtn.isEnabled ? UIColor(named:"SPGreen") : UIColor(named:"SPLight")
        if !signInBtn.isEnabled && !signOutBtn.isEnabled {
            self.showAlert(message: "完成今日簽到囉")
        }
        tbHUD.dismiss()
    }
    
    func getTodaySign(){
        let start = Int(startDay().timeIntervalSince1970)
        let end = Int(endDay().timeIntervalSince1970)
        SignManager.sharedInstance().getRangeSignList(start, end, completion: { (list, error) in
            if error != nil { return }
            for sign in list! {
                if sign.sid == StaffManager.sharedInstance().currentStaff?.sid {
                    self.todaySign = sign
                }
            }
            self.btnSwitch()
        })
    }
    
    func startDay() -> Date {
        let current = Date().toString(format: .isoDate)
        let startOfDay = Date(fromString: "\(current)", format: .isoDate)
        return startOfDay!
    }
    
    func endDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay =  NSCalendar.current.date(byAdding: components, to: startDay())!
        return endOfDay
    }
    
    //MARK: getter
    func checkWifi() {
        WifiManager.sharedInstance().getWifiList(completion: { (wifi, error) in
            let list = wifi?.mac
            tbHUD.dismiss()
            guard let mac = self.getWifi().mac else { return }
            if list?.index(of: mac) == nil{
                self.showAlert(message: "請確認已連結 艾普Wifi")
            } else {
                self.getTodaySign()
            }
        })
    }
    
    func getWifi() -> (ssid: String?, mac: String?){
        guard let name = WifiManager.sharedInstance().getCurrentWifi().ssid
            , let mac = WifiManager.sharedInstance().getCurrentWifi().mac else {
                self.showAlert(message: "請確認已連結 Wifi")
                return(nil, nil)
        }
        return(name, mac)
    }
}
