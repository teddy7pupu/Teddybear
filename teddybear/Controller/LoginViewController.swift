//
//  LoginViewController.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/5.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onGoogleSignIn () {
        GIDSignIn.sharedInstance().signIn()
    }
    
    // MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            return
        }
        guard let authentication = user.authentication else {
            return
        }
        print("[GID] mail:" + user.profile.email)
        //這時候已經GoogleSignIn成功，取得google的accessToken，接著要拿這個token去換Firebase的AuthToken
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        print("[GID] idToken:" + authentication.idToken)
        print("[GID] accessToken:" + authentication.accessToken)
        //Firebase Auth signIn
        Auth.auth().signIn(with: credential) { (user: User!, error: Error!) in
            if let error = error {
                print(error)
                return
            }
            //Firebase登入成功，開啟LobbyView
            print("[Auth] uid:" + user.uid)
            print("[Auth] name:" + user.displayName!)
            print("[Auth] email:" + user.email!)
            self.performSegue(withIdentifier: "SegueLobby", sender: nil)
        }
    }
}

