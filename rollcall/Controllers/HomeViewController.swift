//
//  HomeViewController.swift
//  rollcall
//
//  Created by Samantha Eboli on 1/29/19.
//  Copyright © 2019 Samantha Eboli. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    var userPassedOver : String?
    var captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer!
    let captureMetadataOutput = AVCaptureMetadataOutput()
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        
        //get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr{
            
            if metadataObj.stringValue != nil{
                captureSession.stopRunning()
                directionLabel.text = "Signed in to \(metadataObj.stringValue ?? "an event")!";
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeMessage.text = "Welcome, \(userPassedOver ?? "friend")!"
        
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
