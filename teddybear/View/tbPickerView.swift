//
//  tbPickerView.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

enum tbPickerType {
    case Default
    case MonthYear
    case OfficeHour
    case AnnualSection1
    case AnnualSection2
}

class tbPickerView: UIView
, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerView: UIPickerView!
    var years: [String] = []
    var months: [String] = []
    var officeHours: [String] = []
    let annualHours: [[String]] = [["10:00", "15:00"], ["14:00", "19:00"]]
    
    weak var owner: UITextField?
    
    var dataSource: [String]? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    var type: tbPickerType = .Default {
        didSet {
            switch type {
            case .MonthYear:
                getYearMonthSource()
            case .OfficeHour:
                getOfficeHours()
                dataSource = officeHours
            case .AnnualSection1:
                dataSource = annualHours[0]
            case .AnnualSection2:
                dataSource = annualHours[1]
            default:
                break
            }
            pickerView.reloadAllComponents()
        }
    }
    
    //MARK: Layout
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK: Action
    @IBAction func onCancelAction() {
        owner?.resignFirstResponder()
    }
    
    @IBAction func onDoneAction() {
        var text: String?
        if type == .MonthYear {
            let year = self.years[pickerView.selectedRow(inComponent:0)]
            let month = String(format: "%02d",pickerView.selectedRow(inComponent:1) + 1)
            text = "\(year)-\(month)"
        } else {
            if let source = dataSource?[pickerView.selectedRow(inComponent: 0)] { text = source }
        }
        owner?.text = text
        owner?.sendActions(for: .editingChanged)
        owner?.resignFirstResponder()
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return (type == .MonthYear) ? 2 : 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if type == .MonthYear {
            return (component == 0) ? years.count : months.count
        }
        guard let count = dataSource?.count else { return 0 }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if type == .MonthYear {
            return (component == 0) ? years[row] : months[row]
        }
        return dataSource?[row]
    }
    
    //MARK: Getter
    internal func getYearMonthSource() {
        if years.count == 0, months.count == 0 {
            months = DateFormatter().shortMonthSymbols
            let year: Int = Calendar.current.component(.year, from: Date())
            for count in (year-2)...year {
                years.append("\(count)")
            }
        }
        pickerView.selectRow(2, inComponent: 0, animated: false)
    }
    
    internal func getOfficeHours() {
        if officeHours.count == 0 {
            for n in 10...19 {
                officeHours.append("\(n):00")
            }
        }
    }
}

