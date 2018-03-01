//
//  EntryViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/3/1.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadingView.startAnimating()
        if let user = UserManager.currentUser() {
            getUserProfile(email: user.email)
            return
        }
        openLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Action
    func getUserProfile(email: String!) {
        //Get staff information of user
        StaffManager.sharedInstance().queryStaff(email, completion: { (staff, error) in
            
            if let error = error {
                NSLog("%@", error.localizedDescription)
                //Super Admin
                self.openLobby()
                return
            }
            
            guard staff?.uid != nil else {
                self.updateStaff(staff)
                return
            }
            
            StaffManager.sharedInstance().currentStaff = staff
            self.openLobby()
        })
    }
    
    func updateStaff(_ staff: Staff!) {
        //Update staff information of user
        let user = UserManager.currentUser()
        var updated = staff
        updated?.uid = user?.uid
        updated?.avatar = user?.photoURL?.absoluteString
        StaffManager.sharedInstance().updateStaff(updated) { (aStaff, error) in
            if let error = error {
                NSLog("%@", error.localizedDescription)
                self.showAlert(message: "更新員工資料失敗")
                return
            }
            self.openLobby()
        }
    }
    
    func openLobby() {
        loadingView.stopAnimating()
        if let intern = StaffManager.sharedInstance().currentStaff?.role?.isIntern() {
            if intern {
                self.performSegue(withIdentifier: tbDefines.kSegueIntern, sender: nil)
                return
            }
        }
        self.performSegue(withIdentifier: tbDefines.kSegueLobby, sender: nil)
    }
    
    func openLogin() {
        self.performSegue(withIdentifier: tbDefines.kSegueLogin, sender: nil)
    }
}
