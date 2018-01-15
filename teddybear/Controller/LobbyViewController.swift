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

    @IBOutlet weak var cardView: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.layoutUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Layout & Animation
    func layoutUser() {
        cardView.layoutCardView()
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
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
