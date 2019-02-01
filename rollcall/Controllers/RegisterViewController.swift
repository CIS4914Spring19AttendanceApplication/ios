//
//  RegisterViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var emailPassedOver : String?
    @IBOutlet weak var yearPicker: UIPickerView!
    let yearArr = ["Freshman", "Sophomore", "Junior", "Senior", "Graduate"]
    var year : String?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return yearArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return yearArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        year = yearArr[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.placeholder = emailPassedOver
        emailField.isUserInteractionEnabled = false
        
        yearPicker.delegate = self;
        yearPicker.dataSource = self;
    }
    
    
    @IBAction func register(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
