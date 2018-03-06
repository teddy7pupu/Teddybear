//
//  tbTabBarController.swift
//  teddybear
//
//  Created by JLee21 on 2018/3/7.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

enum tbTabFunction: String {
    case Me = "Me"
    case Approval = "Approval"
    case Leave = "Leave"
    case Report = "Report"
    case Attendance = "Attendance"
    case InterReport = "InternReport"
    
    func icon() -> UIImage {
        switch self {
        case .Me:
            return #imageLiteral(resourceName: "icon_me")
        case .Approval:
            return #imageLiteral(resourceName: "icon_approval")
        case .Leave:
            return #imageLiteral(resourceName: "icon_leave")
        case .Report:
            return #imageLiteral(resourceName: "icon_report")
        case .Attendance:
            return #imageLiteral(resourceName: "icon_attendence")
        case .InterReport:
            return #imageLiteral(resourceName: "icon_report")
        }
    }
}

class tbTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViewControllers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func loadViewControllers() {
        
        let staff = StaffManager.sharedInstance().currentStaff
        var vcIds: [tbTabFunction]
        if staff == nil {
            vcIds = [.Report, .Me]
        } else {
            vcIds = (staff?.role?.functionList())!
        }
        var vcList: [UIViewController] = []
        for vcId in vcIds {
            let root = UIStoryboard(name: vcId.rawValue, bundle: Bundle.main).instantiateInitialViewController()
            root?.tabBarItem.image = vcId.icon()
            vcList.append(root!)
        }
        self.viewControllers = vcList
    }
}
