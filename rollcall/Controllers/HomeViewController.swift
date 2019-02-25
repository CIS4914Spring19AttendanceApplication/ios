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

    let CHECKIN_URL = "http://localhost:8080/api/event/checkIn"
    //let CHECKIN_URL = "http://rollcall-api.herokuapp.com/api/event/checkIn"
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
    var checkInMess : String?
    
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
        //determine whether there are additional fields requested
//        addFields = jsonArr[0]["additional_fields"] as? [Dictionary<String,Any>]
//        if(addFields!.count > 0){
//            //segue to add fields modal pop up
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "additionalQuestions", sender: self)
//            }
//        }
        
        //create the new user in our database
        let parameters: Parameters = [
            "email": userData[0],
            "first_name": userData[1],
            "last_name": userData[2],
            "phone": userData[3],
            "event_id": jsonArr[0]["event_id"]!,
            //"org_id": jsonArr[0]["org_id"]!,
            //"point_categories": jsonArr[0]["point_categories"]!
            //"additional_fields":
        ]
        
        self.sessionManager.adapter = AccessTokenAdapter(accessToken: accessToken!)
        self.sessionManager.request(self.CHECKIN_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON{
            response in
            if let status = response.response?.statusCode{
                switch(status){
                case 201:
                    self.checkInMess = "You have signed in to \(jsonArr[0]["event_name"]!)"
                default:
                    let json = response.result.value as? [String: Any]
                    self.checkInMess = json?["message"] as? String
                }
             
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "signedIn", sender: self)
                }
            }
        }
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
        
        directionLabel.text = "Scan the QR Code to Sign In!";
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "additionalQuestions"{
            let destinationVC = segue.destination as! AdditionalFieldsViewController
            destinationVC.addFields = self.addFields
        }
        
        if segue.identifier == "signedIn"{
            let destinationVC = segue.destination as! SignInViewController
            destinationVC.res = self.checkInMess
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
