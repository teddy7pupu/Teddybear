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
import UserNotifications

class UserManager: NSObject,
UNUserNotificationCenterDelegate, MessagingDelegate {
    
    private static var mInstance: UserManager?
    
    override private init() {
        super.init()
        mAuth = Auth.auth()
    }
    private var mAuth: Auth?
    private var mUser: User? {
        get {
            return mAuth?.currentUser
        }
    }
    
    private var isConfigured = false
    private var cacheMessage: [String: Any]?
    
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
        
        //Firebase Auth signIn with credential
        mAuth?.signIn(with: credential, completion: completion)
    }
    
    func signIn(email: String, password: String, completion:@escaping (User?, Error?) -> Void) {
        //Firebase Auth signIn with Email/Password
        mAuth?.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signOut() {
        do {
            try mAuth?.signOut()
        } catch let signOutError as NSError {
            NSLog("[Auth] Error:%@", signOutError)
        }
        StaffManager.sharedInstance().currentStaff = nil
        NSLog("[Auth] SignOut success")
    }
    
    func launchWithMessage(messageData: [String: Any]?) {
        guard let data = messageData else { return }
        cacheMessage = data
    }
    
    func setupMessenger() {
        if isConfigured {
            return
        }
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        UIApplication.shared.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        Messaging.messaging().subscribe(toTopic: tbDefines.kTopicNews)
    }
    
    func message() -> [String: Any]? {
        guard let message = cacheMessage else { return nil }
        return message
    }
    
    func reset() {
        cacheMessage = nil
    }
}
