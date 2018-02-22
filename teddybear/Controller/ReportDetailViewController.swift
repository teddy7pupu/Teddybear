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
    
    @IBOutlet weak var totalHourLbl: UILabel!
    var staffName : String?
    var staffLeaves: [Leave]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = staffName
        self.totalHourLbl.text = getTotalHour()
    }
    
    func getTotalHour() -> String{
        var summation: Int = 0
        for leave in staffLeaves! {
            let beginDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.startTime!))
            let endDate = Date(timeIntervalSinceReferenceDate: TimeInterval(leave.endTime!))
            let hour = Date.leaveHour(beginDate, leave.startPeriod!, endDate, leave.endPeriod!)
                summation += hour
        }
        return summation > 8 ? String(format:"%.1f天", Double(summation)/8) : "\(summation)小時"
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = staffLeaves?.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportDetailCell.self) , for: indexPath) as! ReportDetailCell
        cell.layoutCell(with: staffLeaves![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
