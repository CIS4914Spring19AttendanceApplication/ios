//
//  HomeViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/29/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import Alamofire
import SCLAlertView

class HomeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {

    //let CHECKIN_URL = "http://localhost:8080/api/event/checkIn"
    let CHECKIN_URL = "http://Samanthas-MacBook-Pro-2.local:8080/api/event/checkIn"
    //let CHECKIN_URL = "http://rollcall-api.herokuapp.com/api/event/checkIn"
    let ADDBOARD_URL = "http://Samanthas-MacBook-Pro-2.local:8080/api/org/addBoard"
    let sessionManager = SessionManager()
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!

    var addFields : [Dictionary<String,Any>]?
    let locationManager = CLLocationManager()
    var longitude : Double?
    var latitutde : Double?
    var eventName : String?
    var parameters : Parameters?
    var additionalQ : [Dictionary<String,Any>] = []
    
    //for establishing the camera
    var captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer!
    let captureMetadataOutput = AVCaptureMetadataOutput()
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        
        //get the metadata object
        guard let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else{
            captureSession.startRunning()
            print("app crashed")
            return
        }

        if metadataObj.type == AVMetadataObject.ObjectType.qr{

            if metadataObj.stringValue != nil{
                captureSession.stopRunning()
                locationManager.startUpdatingLocation()

                let qrJSON = metadataObj.stringValue!
                processQR(qrJSON: qrJSON)
            }
        }
    }
    
    func processQR(qrJSON: String){
        //convert the data to a string
        let data = qrJSON.data(using: String.Encoding.utf8)
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: data!, options : .allowFragments) as? [Dictionary<String,Any>]
            {
                //check whether it is an org or event qr
                if(jsonArray[0]["type"] as! String == "org"){
                    orgEnroll(jsonArr: jsonArray)
                }
                else{
                    eventEnroll(jsonArr: jsonArray)
                }
                
            } else {
                print("invalid data from QR")
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func orgEnroll(jsonArr: [Dictionary<String,Any>]){
        //enroll the user into an organization as a board member
        var enrollMess : String?
        let params = [
            "org_id": jsonArr[0]["org_id"],
            "email": Data.sharedInstance.userData[0]
        ]
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Done", action: {
            self.captureSession.startRunning()
            alert.hideView()
        })
        
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: Data.sharedInstance.accessToken!)
        self.sessionManager.request(self.ADDBOARD_URL, method: .post, parameters: params as Parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    enrollMess = "You have been enrolled as a Board Member in \(jsonArr[0]["org_name"] ?? "this organization")."
                    alert.showSuccess("Success", subTitle: enrollMess ?? "")
                default:
                    let json = response.result.value as? [String: Any]
                    enrollMess = json?["message"] as? String
                    alert.showError("Error", subTitle: enrollMess ?? "")
                }
            }
        }
    }
    
    func eventEnroll(jsonArr: [Dictionary<String,Any>]){
        //check the user into the event
        
        //create the new checkIn in our database
        parameters = [
            "email": Data.sharedInstance.userData[0],
            "first_name": Data.sharedInstance.userData[1],
            "last_name": Data.sharedInstance.userData[2],
            "phone": Data.sharedInstance.userData[3],
            "event_id": jsonArr[0]["event_id"]!,
            "org_id": jsonArr[0]["org_id"]!,
            "point_categories": jsonArr[0]["point_categories"]!
        ]
        eventName = jsonArr[0]["event_name"] as? String
        
        //determine whether there are additional fields requested
        addFields = jsonArr[0]["additional_fields"] as? [Dictionary<String,Any>]
        if(addFields!.count > 0){
            additionalQuestions(addFields: addFields!)
        }
        else{
            checkIn()
        }
    }
    
    func additionalQuestions(addFields: [Dictionary<String,Any>]){
        var additionalQA = [Any]()
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false,
            shouldAutoDismiss: false
        )
        let alert = SCLAlertView(appearance: appearance)
    
        for questions in addFields{
            let q = questions["question"] as? String
            additionalQA.append(q as Any)
            
            let ques = alert.addTextField(q)
            ques.adjustsFontSizeToFitWidth = true;
            additionalQA.append(ques as Any)
        }
        
        alert.addButton("Sign In", action: {
            for i in 0...additionalQA.count{
                //for each text field
                if(i % 2 != 0){
                    //if any of the text fields are empty, then do not allow to submit
                    let textField = additionalQA[i] as? UITextField
                    if(textField!.hasText == false){
                        return
                    }
                }
            }
            
            //if all of the fields have text
            //add the questions and answers to the dictionary
            for i in 0...additionalQA.count{
                //for each text field
                if(i % 2 != 0){
                    let text = additionalQA[i - 1] as? String
                    let textField = additionalQA[i] as? UITextField
                    self.additionalQ.append(["question": text!, "response": textField?.text! as Any])
                }
            }
            self.checkInWithAddFields()
            
            alert.hideView()
        })
        
        alert.addButton("Close", action: {
            self.captureSession.startRunning()
            alert.hideView()
        })
        
         alert.showEdit("Additional Questions", subTitle: "Please provide the following information")
    }
    
    func checkInWithAddFields(){
        parameters?.updateValue(additionalQ, forKey: "additional_questions")
        checkIn()
    }
    
    func checkIn(){
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        
        alert.addButton("Done", action: {
            self.captureSession.startRunning()
            alert.hideView()
        })
        
        var checkInMess : String?
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: Data.sharedInstance.accessToken!)
        self.sessionManager.request(self.CHECKIN_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    checkInMess = "You have signed in to \"\(self.eventName ?? "the event")\". Thanks for coming!"
                    alert.showSuccess("Success", subTitle: checkInMess ?? "")
                default:
                    let json = response.result.value as? [String: Any]
                    checkInMess = json?["message"] as? String
                    alert.showError("uh oh", subTitle: checkInMess ?? "There has been an error. Please try again later.")
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeMessage.text = "Welcome, \(Data.sharedInstance.userData[1])!"
    
        //finds the device's camera
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else{
            print("couldn't find camera")
            return
        }
        
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            //let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            DispatchQueue.main.async{
                self.videoLayer?.frame = self.cameraView.bounds
                self.cameraView.layer.addSublayer(self.videoLayer!)
            }
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            //starts running the camera
            captureSession.startRunning()
            
        } catch{
            print(error)
            return
        }
        
        //set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            latitutde = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //starts running the camera
        captureSession.startRunning()
    }
}
