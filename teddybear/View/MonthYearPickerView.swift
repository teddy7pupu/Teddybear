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
    let year = ["2017","2018","2019","2020","2021","2022"]
    let month = ["01","02","03","04","05","06","07","08","09","10","11","12"]
    //MARK: Layout
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    //MARK: Action
    @IBAction func onCancelAction() {
        owner?.resignFirstResponder()
    }
    
    @IBAction func onDoneAction() {
        let year = self.year[pickerView.selectedRow(inComponent: 1)]
        let month = self.month[pickerView.selectedRow(inComponent: 0)]
        owner?.text = "\(year)-\(month)"
        owner?.sendActions(for: .editingChanged)
        owner?.resignFirstResponder()
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 { return year.count }
        return month.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 { return year[row] }
        return month[row]
    }
}

