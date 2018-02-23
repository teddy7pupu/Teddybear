//
//  SignDetailViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/9.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class SignDetailViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainTable: UITableView!
    private var mlist: [Sign]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = StaffManager.sharedInstance().currentStaff?.name { self.title = "\(name)" }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tbHUD.show()
        getList()
    }
    
    func getList(){
        if let sid = StaffManager.sharedInstance().currentStaff?.sid {
            SignManager.sharedInstance().getSignList(sid, completion: { (list, error) in
                if error != nil { return }
                self.mlist = list
                self.mainTable.reloadData()
                tbHUD.dismiss()
            })
        }
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = mlist?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SignCell.self) , for: indexPath) as! SignCell
        cell.layoutCell(with:mlist?[indexPath.row])
        return cell
    }
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
