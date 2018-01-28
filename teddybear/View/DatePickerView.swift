//
//  DatePickerView.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/16.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class DatePickerView: UIView {
    
    @IBOutlet weak var pickerView: UIDatePicker!
    weak var owner: UITextField?
    var maximumDate: Date?
    
    //MARK: Layout
    override func awakeFromNib() {
        super.awakeFromNib()
        if let maxDate = maximumDate {
            pickerView.maximumDate = maxDate
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard owner?.text! != "" else {
            pickerView.date = Date()
            return
        }
        let dateString = owner?.text!
        pickerView.date = Date(fromString: dateString!, format: .isoDate)!
    }
    
    //MARK: Action
    @IBAction func onCancelAction() {
        owner?.resignFirstResponder()
    }
    
    @IBAction func onDoneAction() {
        owner?.text = pickerView.date.toString(format: .isoDate)
        owner?.sendActions(for: .editingChanged)
        owner?.resignFirstResponder()
    }
}
