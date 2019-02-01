//
//  RegisterViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/30/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  
    @IBOutlet weak var emailField: UITextField!
    var emailPassedOver : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailField.placeholder = emailPassedOver
        emailField.isUserInteractionEnabled = false
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
