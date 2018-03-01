//
//  InternViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import GoogleSignIn

class InternViewController: UITableViewController {

    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.layoutUser()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    func layoutUser() {
        if let user = currentStaff {
            englishLbl.text = user.english
            nameLbl.text = user.name
            titleLbl.text = user.title
        } else {
            englishLbl.text = "Admin"
            nameLbl.text = "管理員"
            titleLbl.text = "AppMaster Co.,Ltd."
        }
    }
    
    //MARK: Action
    @IBAction func onGoogleSignOut () {
        //記得要把GoogleSignIn也登出喔
        GIDSignIn.sharedInstance().signOut()
        UserManager.sharedInstance().signOut()
        //登出成功，回到上一頁
        self.dismiss(animated: true) {
            
        }
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
