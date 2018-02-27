//
//  LobbyViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/5.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import GoogleSignIn

class LobbyViewController: UITableViewController {
    
    @IBOutlet weak var approvalBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
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
            leaveBtn.isEnabled = false
            approvalBtn.isEnabled = false
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
    
    //MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard let count = currentStaff?.role?.functionList() else { return 5}
            return count
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
