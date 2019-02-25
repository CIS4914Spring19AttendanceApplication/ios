//
//  SignInViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 2/23/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    var res : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultLabel.text = self.res
    }
    
    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
