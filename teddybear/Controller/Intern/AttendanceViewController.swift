//
//  AttendanceViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork

class AttendanceViewController: UIViewController {
    
    internal enum SignStatus: Int {
        case Empty
        case ClockIn
        case Finish
        
        static func getStatus(_ sign: Sign?) -> SignStatus {
            guard let sign = sign else { return .Empty }
            
            if sign.startTime != nil, sign.endTime == nil {
                return .ClockIn
            }
            
            if sign.startTime != nil, sign.endTime != nil {
                return .Finish
            }
            return .Empty
        }
    }
    
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var wifiLbl: UILabel!
    private var todaySign: Sign?
    private var timer: Timer?
    private var wifiAvailable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_timer) in
            self.layoutDateTime()
        })
    }
    
    deinit {
        timer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkWifi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tbHUD.dismiss()
    }
    
    //MARK: Layout & Animation
    internal func setupLayout() {
        signInBtn.setBackgroundImage(UIColor.SPGreen.image(), for: .normal)
        signOutBtn.setBackgroundImage(UIColor.SPGreen.image(), for: .normal)
        signInBtn.setBackgroundImage(UIColor.SPLight.image(), for: .disabled)
        signOutBtn.setBackgroundImage(UIColor.SPLight.image(), for: .disabled)
    }
    
    internal func layoutDateTime() {
        let date = Date()
        dateLbl.text = "\(date.toString(format: .custom("MM月dd日"))) \(date.toString(style: .weekday))"
        timeLbl.text = date.toString(format: .custom("HH:mm:ss"))
    }
    
    internal func layoutButtons() {
        if !wifiAvailable {
            signInBtn.isEnabled = false
            signOutBtn.isEnabled = false
            return
        }
        
        let status = SignStatus.getStatus(todaySign)
        switch status {
        case .Empty:
            signInBtn.isEnabled = true
            signOutBtn.isEnabled = false
            break
        case .ClockIn:
            signInBtn.isEnabled = false
            signOutBtn.isEnabled = true
            let begin = Date(timeIntervalSince1970: Double((todaySign?.startTime)!)).toString(format: .isoTime)
            signInBtn.setTitle("已完成簽到 \(begin)", for: .disabled)
            break
        case .Finish:
            signInBtn.isEnabled = false
            signOutBtn.isEnabled = false
            let begin = Date(timeIntervalSince1970: Double((todaySign?.startTime)!)).toString(format: .isoTime)
            let end = Date(timeIntervalSince1970: Double((todaySign?.endTime)!)).toString(format: .isoTime)
            signInBtn.setTitle("已完成簽到 \(begin)", for: .disabled)
            signOutBtn.setTitle("已完成簽退 \(end)", for: .disabled)
            break
        }
    }
    
    //MARK: Action
    @IBAction func checkWifi() {
        tbHUD.show()
        wifiLbl.text = "---"
        WifiManager.sharedInstance().getWifiList( completion: { (wifi, error) in
            let list = wifi?.mac
            tbHUD.dismiss()
            if let mac = self.getWifi().mac {
                self.wifiAvailable = (list?.index(of: mac) != nil)
            }
            if let ssid = self.getWifi().ssid {
                DispatchQueue.main.async {
                    self.wifiLbl.text = "SSID: \(ssid)"
                }
            }
            
            self.getTodaySign()
            if !self.wifiAvailable {
                self.showAlert(message: "請確認已連結公司Wifi")
            }
        })
    }
    
    @IBAction func onSignOut(_ sender: Any) {
        self.showAlert(message: "確定要簽到嗎？", completion: {
            tbHUD.show()
            self.reviseSign(startTime: nil, endTime: Int(Date().timeIntervalSince1970))
        })
        
    }
    
    @IBAction func onSignIn(_ sender: Any) {
        self.showAlert(message: "確定要簽退嗎？", completion: {
            tbHUD.show()
            self.reviseSign(startTime: Int(Date().timeIntervalSince1970) , endTime: nil)
        })
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
            DispatchQueue.main.async {
                self.layoutButtons()
            }
        })
    }
    
    func updateSign(sign: Sign) {
        SignManager.sharedInstance().updateSignData(sign) { (sign, error) in
            tbHUD.dismiss()
            self.todaySign = sign
            DispatchQueue.main.async {
                self.layoutButtons()
            }
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
    
    //MARK: Getter
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
    
    //MARK: Wifi
    func getWifi() -> (ssid: String?, mac: String?) {
        let wifi = WifiManager.sharedInstance().getCurrentWifi()
        return(wifi.ssid, wifi.mac)
    }
}
