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

class HomeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CLLocationManagerDelegate {

    //let CHECKIN_URL = "http://localhost:8080/api/event/checkIn"
    //let CHECKIN_URL = "http://Samanthas-MacBook-Pro-2.local:8080/api/event/checkIn"
    let CHECKIN_URL = "http://rollcall-api.herokuapp.com/api/event/checkIn"
     let sessionManager = SessionManager()
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    var userData : [String] = []
    var accessToken : String?
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
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
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
                if(jsonArray[0]["type"] as! String == "organization"){
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
        
    }
    
    func eventEnroll(jsonArr: [Dictionary<String,Any>]){
        //check the user into the event
        
        //create the new checkIn in our database
        parameters = [
            "email": userData[0],
            "first_name": userData[1],
            "last_name": userData[2],
            "phone": userData[3],
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
        let alert = UIAlertController(title: "Additional Questions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            self.viewDidAppear(false)
        }))
        
        for questions in addFields{
            let q = questions["question"] as? String
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.text = q
                textField.textAlignment = .center
                textField.isEnabled = false
                textField.backgroundColor = UIColor.clear
                textField.borderStyle = UITextField.BorderStyle.none
                textField.adjustsFontSizeToFitWidth = true
            })
            
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "Answer..."
            })
        }
        
        let submitAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            //create the dictionary for questions and answers
            for i in 0...alert.textFields!.count{
                if(i % 2 != 0){
                    self.additionalQ.append(["question": alert.textFields![i - 1].text!, "response": alert.textFields![i].text!])
                }
            }
            self.checkInWithAddFields()
        })
        alert.addAction(submitAction)
        
        self.present(alert, animated: true)
    }
    
    func checkInWithAddFields(){
        parameters?.updateValue(additionalQ, forKey: "additional_questions")
        checkIn()
    }
    
    func checkIn(){
        var checkInMess : String?
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: accessToken!)
        self.sessionManager.request(self.CHECKIN_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    let json = response.result.value as? [String: Any]
                    let eventName = json?["message"] as? String
                    checkInMess = "You have signed in to \(eventName ?? "the event")"
                default:
                    let json = response.result.value as? [String: Any]
                    checkInMess = json?["message"] as? String
                }
                
                self.signInSuccess(message: checkInMess!);
            }
        }
    }
    
    func signInSuccess(message: String){
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.viewDidAppear(false)
        }))
        
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeMessage.text = "Welcome, \(userData[1])!"
    
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
            captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
            
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
