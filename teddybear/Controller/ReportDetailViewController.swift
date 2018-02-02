//
//  ReportDetailViewController.swift
//  teddybear
//
//  Created by RD-Ops02 on 2018/2/2.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class ReportDetailViewController: UIViewController
,UITableViewDataSource, UITableViewDelegate {
    
    var staffName : String?
    var staffLeaves: [Leave]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = staffName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = staffLeaves?.count else {return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportDetailCell.self) , for: indexPath) as! ReportDetailCell
        //cell.layoutCell(with: self.staffLeaveList?[indexPath.row])
        return cell
    }
}
