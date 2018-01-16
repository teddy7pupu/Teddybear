//
//  LoginViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/5.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onGoogleSignIn () {
        //GoogleSignIn沒辦法包進UserManager裡，因為callback的uiDelegate檢查會觸發exception，所以需要拉到controller做掉
        let signIn = GIDSignIn.sharedInstance()
        signIn?.clientID = tbDefines.FIRClientID
        signIn?.delegate = self
        signIn?.uiDelegate = self
        
        signIn?.signIn()
    }
    
    //MARK: Action
    func getUserProfile(email: String!) {
        //Get staff information of user
        StaffManager.sharedInstance().queryStaff(email, completion: { (staff, error) in
            if let error = error {
                NSLog("[USER] error: %@", error.localizedDescription)
                return
            }
            
            guard staff?.uid != nil else {
                self.updateStaff(staff)
                return
            }
            self.performSegue(withIdentifier: "SegueLobby", sender: nil)
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
                NSLog("[USER] error: %@", error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "SegueLobby", sender: nil)
        }
    }
    
    //MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            NSLog("[GID] error: %@", error.localizedDescription)
            return
        }
        
        //檢查是否為公司網域
        let email = user.profile.email
        if false == email?.contains(tbDefines.AMDomain) {
            NSLog("[GID] Error domain: %@", email!)
            signIn.signOut()
            return
        }
        
        UserManager.sharedInstance().signIn(user: user) { (user: User!, error: Error!) in
            self.getUserProfile(email: email)
        }
    }
}

