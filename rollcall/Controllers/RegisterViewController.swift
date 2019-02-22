//
//  RegisterViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
  
    let REGISTER_URL = "http://localhost:8080/api/user/registeruser"
    let sessionManager = SessionManager()
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var emailPassedOver : String?
    var accessToken : String?
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
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: accessToken!)
        
        //check that no fields are empty
        if(!firstNameField.hasText){
            warningLabel.isHidden = false
            return
        }
        if(!lastNameField.hasText){
            warningLabel.isHidden = false
            return
        }
        
        //create the new user in our database
        let parameters: Parameters = [
            "email": emailPassedOver!,
            "first_name": firstNameField.text!,
            "last_name": lastNameField.text!,
            "year": year!
        ]
        
        self.sessionManager.request(self.REGISTER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goFromRegToHome", sender: self)
                    }
                case 400:
                    self.warningLabel.isHidden = true
                    self.errorLabel.isHidden = false
                default:
                    print("Default \(status)")
                }
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFromRegToHome"{
            let barController = segue.destination as! UITabBarController
            let destinationVC = barController.viewControllers![0] as! HomeViewController
            destinationVC.userPassedOver = firstNameField.text
            destinationVC.email = self.emailPassedOver
            destinationVC.accessToken = self.accessToken
        }
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
