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

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var bearBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.text = nil
        pwdField.text = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: Layout & Animation
    func setupLayout() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardDismiss(gesture:)))
        gesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gesture)
        
        emailField.tbSetup()
        pwdField.tbSetup()
        loginBtn.tbSetup()
        googleBtn.tbSetup()
    }
    
    //MARK: Action
    @IBAction func onEmailSignIn () {
        guard let email = emailField.text, let pwd = pwdField.text else {
            self.showAlert(message: "請輸入正確登入資訊")
            return
        }
        tbHUD.show()
        UserManager.sharedInstance().signIn(email: email, password: pwd) { (user, error) in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.dismiss()
        }
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
    
    func dismiss() {
        tbHUD.dismiss()
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onBearBtn() {
        bearBtn.pop()
    }
    
    //MARK: GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            NSLog("%@", error.localizedDescription)
            self.showAlert(message: "登入失敗")
            return
        }
        
        //檢查是否為公司網域
        let email = user.profile.email
        if false == email?.contains(tbDefines.AMDomain) {
            self.showAlert(message: "這不是AppMaster員工帳號喔！")
            signIn.signOut()
            return
        }
        
        UserManager.sharedInstance().signIn(user: user) { (user: User!, error: Error!) in
            self.dismiss()
        }
    }
}

internal extension UITextField {
    func tbSetup() {
        self.layer.cornerRadius = 5
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        self.attributedPlaceholder = NSAttributedString(string:self.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightText])
    }
}

internal extension UIButton {
    func tbSetup() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.SPGreen.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}

internal extension UIView {
    func pop() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: "linear")
        animation.duration = 0.6
        animation.values = [-20, 20, -20, 20, -10, 10, -5, 5, 0]
        animation.isRemovedOnCompletion = true
        self.layer.add(animation, forKey: "pop")
    }
}
