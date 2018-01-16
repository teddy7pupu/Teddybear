//
//  UserManager.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/5.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

class UserManager: NSObject {
    
    private static var mInstance: UserManager?
    override private init() {
        super.init()
    }
    
    private var mUser: User?
    
    // MARK: Public method
    static func sharedInstance() -> UserManager {
        if mInstance == nil {
            mInstance = UserManager()
        }
        return mInstance!
    }
    
    static func currentUser() -> User? {
        return UserManager.sharedInstance().mUser
    }
    
    func signIn(user: GIDGoogleUser, completion:@escaping (User?, Error?) -> Void) {
        guard let authentication = user.authentication else {
            let error = NSError(domain: tbDefines.BUNDLEID, code: -1, userInfo: [NSLocalizedDescriptionKey: "錯誤的GoogleUser"])
            completion(nil, error)
            return
        }
        
        //這時候已經GoogleSignIn成功，取得google的accessToken，接著要拿這個token去換Firebase的AuthToken
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        //Firebase Auth signIn
        Auth.auth().signIn(with: credential) { (user: User!, error: Error!) in
            if let error = error {
                completion(nil, error)
                return
            }
            self.mUser = user
            completion(user, nil)
        }
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            NSLog("[Auth] Error:%@", signOutError)
        }
        NSLog("[Auth] SignOut success")
    }
}
