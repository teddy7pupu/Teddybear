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
        
        tbHUD.show()
        signIn?.signIn()
    }
    
    //MARK: Action
    func getUserProfile(email: String!) {
        //Get staff information of user
        StaffManager.sharedInstance().queryStaff(email, completion: { (staff, error) in
            
            if let error = error {
                NSLog("%@", error.localizedDescription)
                tbHUD.dismiss()
                UIAlertController.alert(message: "無此員工資料").otherHandle(alertAction: nil).show(currentVC: self)
                return
            }
            
            guard staff?.uid != nil else {
                self.updateStaff(staff)
                return
            }
            tbHUD.dismiss()
            self.performSegue(withIdentifier: tbDefines.kSegueLobby, sender: nil)
        })
    }
    
    func updateStaff(_ staff: Staff!) {
        //Update staff information of user
        let user = UserManager.currentUser()
        var updated = staff
        updated?.uid = user?.uid
        updated?.avatar = user?.photoURL?.absoluteString
        StaffManager.sharedInstance().updateStaff(updated) { (aStaff, error) in
            tbHUD.dismiss()
            if let error = error {
                NSLog("%@", error.localizedDescription)
                UIAlertController.alert(message: "更新員工資料失敗").otherHandle(alertAction: nil).show(currentVC: self)
                return
            }
            self.performSegue(withIdentifier: tbDefines.kSegueLobby, sender: nil)
        }
    }
    
    //MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            NSLog("%@", error.localizedDescription)
            tbHUD.dismiss()
            UIAlertController.alert(message: "登入失敗").otherHandle(alertAction: nil).show(currentVC: self)
            return
        }
        
        //檢查是否為公司網域
        let email = user.profile.email
        if false == email?.contains(tbDefines.AMDomain) {
            tbHUD.dismiss()
            UIAlertController.alert(message: "這不是AppMaster員工帳號喔！").otherHandle(alertAction: nil).show(currentVC: self)
            signIn.signOut()
            return
        }
        
        UserManager.sharedInstance().signIn(user: user) { (user: User!, error: Error!) in
            self.getUserProfile(email: email)
        }
    }
}

