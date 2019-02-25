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
    
    let ONBOARD_URL = "http://rollcall-api.herokuapp.com/api/user/onboardcheck/"
    //let ONBOARD_URL = "http://localhost:8080/api/user/onboardcheck/"
    let sessionManager = SessionManager()
    
    var accessToken : String?
    var userData : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func signIn(_ sender: UIButton) {
        
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://rollcall-api.herokuapp.com")
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
                    self.sessionManager.adapter = AccessTokenAdapter(accessToken: accessToken)
                    self.accessToken = accessToken
                    
                    Auth0
                        .authentication()
                        .userInfo(withAccessToken: accessToken)
                        .start { result in
                            switch(result) {
                            case .success(let profile):
                                
                                if let name = profile.name {
                                    self.userData.append(name)
                                    
                                    //check if the user is already in our database
                                    let completeURL = self.ONBOARD_URL + name
                                    self.sessionManager.request(completeURL, method: .get, encoding: JSONEncoding.default).responseJSON{
                                        response in
                                        if let status = response.response?.statusCode{
                                            print("status \(status)")
                                            switch(status){
                                            case 200:
                                                let json = response.result.value as? [String: Any]
                                                self.userData.append(json?["first_name"] as! String)
                                                self.userData.append(json?["last_name"] as! String)
                                                self.userData.append(json?["phone"] as? String ?? "" )
                                                
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
            let barController = segue.destination as! UITabBarController
            let destinationVC = barController.viewControllers![0] as! HomeViewController
            destinationVC.userData = self.userData
            destinationVC.accessToken = self.accessToken
        }
        
        if segue.identifier == "goToRegistration"{
            let destinationVC = segue.destination as! RegisterViewController
            destinationVC.emailPassedOver = self.userData[0]
            destinationVC.accessToken = self.accessToken
        }
    }
}

