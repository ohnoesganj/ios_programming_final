//
//  PlanDetailViewController.swift
//  ch10-leejaemoon-stackView
//
//  Created by jmlee on 2023/04/27.
//

import UIKit

class PlanDetailViewController: UIViewController {

    @IBOutlet weak var dateDatePicker: UIDatePicker!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var typePicker: UIPickerView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    
    var plan: Plan?
    var saveChangeDelegate: ((Plan)->Void)?
    var isChecked: String? = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        typePicker.dataSource = self
        typePicker.delegate = self
        
        plan = plan ?? Plan(date: Date(), withData: true)
        dateDatePicker.date = plan?.date ?? Date()
        ownerLabel.text = plan?.owner       // plan!.owner과 차이는? optional chainingtype

        // typePickerView 초기화
        if let plan = plan{
            typePicker.selectRow(plan.kind.rawValue, inComponent: 0, animated: false)
        }
        contentTextView.text = plan?.content
        if plan?.isChecked == "false" {
            DoneButton.isSelected = false
        } else {
            DoneButton.isSelected = true
        }
    }

    
    @IBAction func Done(_ sender: UIButton) {
        if sender.isSelected == false {
            isChecked = "Done"
            sender.isSelected = true
        } else {
            isChecked = "Undone"
            sender.isSelected = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        plan!.date = dateDatePicker.date
        plan!.owner = ownerLabel.text    // 수정할 수 없는 UILabel이므로 필요없는 연산임
        plan!.kind = Plan.Kind(rawValue: typePicker.selectedRow(inComponent: 0))!
        plan!.content = contentTextView.text
        plan!.isChecked = String(DoneButton.isSelected)
        
        print(String(DoneButton.isSelected))

        saveChangeDelegate?(plan!)
    }
    
}


extension PlanDetailViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Plan.Kind.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let type = Plan.Kind.init(rawValue: row)
        return type?.toString()
    }
    
}
