//
//  tbHUD.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/17.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class tbHUD {
    // MARK: Public method
    static func show() {
        guard let hud = tbHUD.sharedInstance() else { return }
        if !Thread.current.isMainThread {
            DispatchQueue.main.async {
                tbHUD.show()
            }
            return
        }
        
        if hud.hudView != nil, hud.hudActivity != nil {
            dismiss()
        }
        
        if let current = currentViewController() {
            let container = UIView()
            container.frame = current.view.frame
            container.center = current.view.center
            container.backgroundColor = UIColor.clear
            
            let loadingView = UIActivityIndicatorView()
            loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            loadingView.center = container.center
            loadingView.activityIndicatorViewStyle = .whiteLarge
            loadingView.backgroundColor = UIColor(named:"SPDark")
            loadingView.color = UIColor(named:"SPGreen")
            loadingView.layer.cornerRadius = 10
            loadingView.clipsToBounds = true
            loadingView.hidesWhenStopped = true
            container.addSubview(loadingView)
            
            hud.hudView = container
            hud.hudActivity = loadingView
            
            current.view.addSubview(container)
            loadingView.startAnimating()
        }
    }
    
    static func dismiss() {
        guard let hud = tbHUD.sharedInstance() else { return }
        
        if !Thread.current.isMainThread {
            DispatchQueue.main.async {
                tbHUD.dismiss()
            }
            return
        }
        hud.hudActivity?.stopAnimating()
        UIView.animate(withDuration: 0.5, animations: {
            hud.hudView?.alpha = 0
        }) { (finish) in
            hud.hudView?.removeFromSuperview()
            hud.hudView = nil
        }
    }
    
    // MARK: Private method
    private static var mInstance: tbHUD?
    private static func sharedInstance() -> tbHUD? {
        if mInstance == nil {
            mInstance = tbHUD()
        }
        return mInstance
    }
    
    private var hudView: UIView?
    private var hudActivity: UIActivityIndicatorView?
    
    private static func currentViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    
}
