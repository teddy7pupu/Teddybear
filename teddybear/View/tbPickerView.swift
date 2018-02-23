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
}

class tbPickerView: UIView
, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerView: UIPickerView!
    var years: [String] = []
    var months: [String] = []
    
    weak var owner: UITextField?
    
    var dataSource: [String]? {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    var type: tbPickerType = .Default {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    //MARK: Layout
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if type == .MonthYear {
            getYearMonthSource()
        }
    }
    
    //MARK: Action
    func getYearMonthSource() {
        years = []
        months = DateFormatter().shortMonthSymbols
        let year: Int = Calendar.current.component(.year, from: Date())
        for count in (year-2)...year {
            years.append("\(count)")
        }
    }
    
    @IBAction func onCancelAction() {
        owner?.resignFirstResponder()
    }
    
    @IBAction func onDoneAction() {
        var text: String?
        if type == .MonthYear {
            let year = self.years[pickerView.selectedRow(inComponent: 0)]
            let month = self.months[pickerView.selectedRow(inComponent: 1)]
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
}

