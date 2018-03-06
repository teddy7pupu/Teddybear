//
//  LobbyViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/5.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import GoogleSignIn

class MeViewController: UIViewController {
    
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var wifiBtn: UIButton!
    @IBOutlet weak var gameBtn: UIButton!
    
    private var currentStaff: Staff? = StaffManager.sharedInstance().currentStaff
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layoutUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail {
            let info = segue.destination as! MeInfoViewController
            info.staff = currentStaff
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    func setupLayout() {
        avatarImg.layer.cornerRadius = 0.5 * avatarImg.bounds.height
        contactBtn.layer.cornerRadius = 0.5 * contactBtn.bounds.height
        wifiBtn.layer.cornerRadius = 0.5 * wifiBtn.bounds.height
        gameBtn.layer.cornerRadius = 0.5 * gameBtn.bounds.height
    }
    
    func layoutUser() {
        if let staff = currentStaff {
            if let avatar = staff.avatar {
                avatarImg.sd_setImage(with: URL(string: avatar), completed: nil)
            }
            nameLbl.text = staff.name
            englishLbl.text = staff.english
            wifiBtn.isEnabled = false
        } else {
            avatarImg.image = nil
            nameLbl.text = "管理員"
            englishLbl.text = "Admin"
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
}
