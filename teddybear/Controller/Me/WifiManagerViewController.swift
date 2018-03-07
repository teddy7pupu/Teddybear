//
//  WifiManagerViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/22.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class WifiManagerViewController: UITableViewController {
    
    @IBOutlet weak var wifiName: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var wifiMac: UILabel!
    var wifiList: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getWifiList()
    }
    
    //MARK: Layout & Animation
    internal func setupLayout() {
        self.title = "Wifi 管理"
        addBtn.setBackgroundImage(UIColor.SPGreen.image(), for: .normal)
        addBtn.setBackgroundImage(UIColor.SPLight.image(), for: .disabled)
        deleteBtn.setBackgroundImage(UIColor.SPGreen.image(), for: .normal)
        deleteBtn.setBackgroundImage(UIColor.SPLight.image(), for: .disabled)
    }
    
    //MARK: Action
    @IBAction func onAdd(_ sender: Any) {
        var newWifi = Wifi()
        var list: [String] = []
        if wifiList != nil {
            list = wifiList!
            list.append(wifiMac.text!)
            wifiList = list
        } else {
            wifiList = [wifiMac.text!]
        }
        newWifi.mac = wifiList
        updateWifi(newWifi)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        var newWifi = Wifi()
        var list: [String] = []
        list = wifiList!
        guard let set = list.index(of: wifiMac.text!) else {
            return
        }
        list.remove(at: set)
        wifiList = list
        newWifi.mac = wifiList
        updateWifi(newWifi)
    }
    
    func updateWifi(_ newWifi: Wifi?) {
        tbHUD.show()
        WifiManager.sharedInstance().updateWifiData(newWifi) { (wifi, error) in
            self.getWifiList()
            tbHUD.dismiss()
            self.showAlert(message: "更新完成")
        }
    }
    
    func checkWifi(){
        if let mac = getWifi().mac {
            if wifiList?.index(of: mac) != nil {
                addBtn.isEnabled = false
                deleteBtn.isEnabled = true
            } else {
                addBtn.isEnabled = true
                deleteBtn.isEnabled = false
            }
        }
        tbHUD.dismiss()
    }
    
    //MARK: getter
    func getWifiList() {
        tbHUD.show()
        WifiManager.sharedInstance().getWifiList(completion: { (wifi, error) in
            self.wifiList = wifi?.mac
            self.checkWifi()
        })
    }
    
    func getWifi() -> (ssid: String?, mac: String?) {
        guard let name = WifiManager.sharedInstance().getCurrentWifi().ssid
            , let mac = WifiManager.sharedInstance().getCurrentWifi().mac else {
            self.showAlert(message: "請確認已連結 Wifi")
            return(nil, nil)
        }
        wifiName.text = name
        wifiMac.text = mac
        return(name, mac)
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
