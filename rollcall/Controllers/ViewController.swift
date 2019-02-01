//
//  ViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/23/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import Auth0
import Alamofire

class ViewController: UIViewController {
    
    let ONBOARD_URL = "http://localhost:8080/api/user/onboardcheck"
    
    var userName : String?
    var firstName : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    @IBAction func signIn(_ sender: UIButton) {
        
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
                                    
                                    //check if the user is already in our database
                                    let parameters: Parameters = [
                                        "email": name
                                    ]
                                    Alamofire.request(self.ONBOARD_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                                        response in
                                        if let status = response.response?.statusCode{
                                            print("status \(status)")
                                            switch(status){
                                            case 200:
                                                let json = response.result.value as? [String: Any]
                                                self.firstName = json?["first_name"] as? String
                                                
                                                //go to the home screen
                                                DispatchQueue.main.async {
                                                    self.performSegue(withIdentifier: "goToHome", sender: self)
                                                }
                                            case 404:
                                                //go to the user registration screen
                                                DispatchQueue.main.async {
                                                    self.performSegue(withIdentifier: "goToRegistration", sender: self)
                                                }
                                            default:
                                                print("Default")
                                            }
                                        }
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
            destinationVC.userPassedOver = firstName
            
        }
        
        if segue.identifier == "goToRegistration"{
            let destinationVC = segue.destination as! RegisterViewController
            destinationVC.emailPassedOver = userName
        }
    }
}

