//
//  ViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/23/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import Auth0

class ViewController: UIViewController {
    
    var userName : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func signIn(_ sender: UIButton) {
        
        var signedIn : Bool
        
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://rollcall-app.auth0.com/userinfo")
            .start {
                switch $0 {
                case .failure(let error):
                    // Handle the error
                    print("Error: \(error)")
                case .success(let credentials):
                    // Do something with credentials e.g.: save them.
                    // Auth0 will automatically dismiss the login page
                    
                    print("Successful Log in")
                    guard let accessToken = credentials.accessToken
                        else{
                            assert(false, "Google Analytics not configured correctly")
                    }
                    print("1: \(accessToken)")
                    
                    Auth0
                        .authentication()
                        .userInfo(withAccessToken: accessToken)
                        .start { result in
                            switch(result) {
                            case .success(let profile):
                                
                                if let name = profile.name {
                                    self.userName = name
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "goToHome", sender: self)
                                    }
                          
                                }
                            case .failure(let error):
                                // Handle the error
                                print("Error: \(error)")
                            }
                    }
                    
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHome"{
            let destinationVC = segue.destination as! HomeViewController
            destinationVC.userPassedOver = userName
            
        }
    }
}

