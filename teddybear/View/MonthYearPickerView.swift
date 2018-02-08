//
//  tbPickerView.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class MonthYearPickerView: UIView
, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerView: UIPickerView!
    weak var owner: UITextField?
    var years: [String] = []
    var months: [String] = []
    let formatter = DateFormatter()
    
    //MARK: Layout
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        getYearMonthSource()
        super.layoutSubviews()
    }
    
    //MARK: Action
    @IBAction func onCancelAction() {
        owner?.resignFirstResponder()
    }
    
    @IBAction func onDoneAction() {
        let year = self.years[pickerView.selectedRow(inComponent: 0)]
        let month = self.months[pickerView.selectedRow(inComponent: 1)]
        owner?.text = "\(year)-\(month)"
        owner?.sendActions(for: .editingChanged)
        owner?.resignFirstResponder()
    }
    
    func getYearMonthSource() {
        years = []
        formatter.locale = Locale(identifier: "zh_TW")
        months = formatter.shortMonthSymbols
        let year: Int = Calendar.current.component(.year, from: Date())
        for count in (year-2)...(year+2) {
            years.append("\(count)")
        }
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return years.count }
        return months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return years[row] }
        return months[row]
    }
}

