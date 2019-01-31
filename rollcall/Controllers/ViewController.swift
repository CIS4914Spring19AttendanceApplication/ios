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
    
    var userName : String?

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
                                    
                                    print("about to test API")
                                    
                                    //check if the user is already in our database
                                    let parameters: Parameters = [
                                        "email": name
                                    ]
                                    Alamofire.request("http://localhost:8080/api/user/onboardcheck", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
                                        response in
                                        if let status = response.response?.statusCode{
                                            switch(status){
                                            case 200:
                                                print("User Exists")
                                            default:
                                                print("User Not Found")
                                            }
                                        }
                                    }
                                    
                                    
                                    /*DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "goToHome", sender: self)
                                    }*/
                          
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

