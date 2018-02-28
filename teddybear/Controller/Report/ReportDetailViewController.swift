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
    
    var name : String?
    var staffLeaves: [Leave]?
    var internSigns: [Sign]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if staffLeaves != nil {
            let total = getTotalHour()
            self.title = name! + " (\(total))"
        } else {
            self.title = name
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tbDefines.kSegueDetail, let leave = sender as? Leave {
            let detailView = segue.destination as! LeaveDetailViewController
            detailView.currentLeave = leave
        }
    }
    
    //MARK: Layout & Animation
    func getTotalHour() -> String {
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
        guard let count = staffLeaves?.count else { return (internSigns?.count)! }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if staffLeaves != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ReportDetailCell.self) , for: indexPath) as! ReportDetailCell
            cell.layoutCell(with: staffLeaves![indexPath.row])
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: "InternReportDetailCell") , for: indexPath) as! ReportDetailCell
        cell.layoutCell(with: internSigns![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let leaves = staffLeaves else { return }
        performSegue(withIdentifier: tbDefines.kSegueDetail, sender: leaves[indexPath.row])
    }
}
