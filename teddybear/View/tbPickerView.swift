//
//  tbPickerView.swift
//  teddybear
//
//  Created by JLee21 on 2018/1/18.
//  Copyright © 2018年 AppMaster Co.,Ltd. All rights reserved.
//

import UIKit

class tbPickerView: UIView
, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var pickerView: UIPickerView!
    weak var owner: UITextField?
    var dataSource: [String]?
    
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
        owner?.text = (dataSource?[pickerView.selectedRow(inComponent: 0)])!
        owner?.sendActions(for: .editingChanged)
        owner?.resignFirstResponder()
    }
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let count = dataSource?.count else {return 0 }
        return count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource?[row]
    }
}
