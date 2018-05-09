//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Mikheil Gotiashvili on 7/14/17.
//  Copyright © 2017 Mikheil Gotiashvili. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate {

    @IBOutlet weak var PreviewView: UIView!
    var captureDevice:AVCaptureDevice?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var captureSession:AVCaptureSession?
    let headerSize = 205.0
    let height = 305.0
    var isHidden = true
    
    var products = [String : Int]()
    var prices = [String : Int]()
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func didPressToScan(_ sender: Any) {
        // Calculate new frame size for the table header
        var newRect = tableView.frame
        newRect.origin.y = CGFloat(isHidden ? 50 : headerSize);
        newRect.size.height = CGFloat(isHidden ? headerSize : 0) + CGFloat(height-50)

        // Get the reference to the header view
        // Animate the height change
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            self.isHidden = !self.isHidden
            self.tableView.frame = newRect
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Scanner"
        view.backgroundColor = .white
        
        captureDevice = AVCaptureDevice.default(for: .video)
        // Check if captureDevice returns a value and unwrap it
        if let captureDevice = captureDevice {
        
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                captureSession = AVCaptureSession()
                guard let captureSession = captureSession else { return }
                captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13,  .ean8, .code39] //AVMetadataObject.ObjectType
                
                captureSession.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                videoPreviewLayer?.frame = PreviewView.layer.bounds
                PreviewView.layer.addSublayer(videoPreviewLayer!)
                
            } catch {
                print("Error Device Input")
            }
        }
        
//        view.addSubview(codeLabel)
//        codeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        codeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        codeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        codeLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
//
    }
    
    let codeLabel:UILabel = {
        let codeLabel = UILabel()
        codeLabel.backgroundColor = .white
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        return codeLabel
    }()
    
    let codeFrame:UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if isHidden {
            return
        }
        
        if metadataObjects.count == 0 {
            //print("No Input Detected")
            codeFrame.frame = CGRect.zero
            codeLabel.text = "No Data"
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }
        
//        view.addSubview(codeFrame)
        
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        codeFrame.frame = barcodeObject.bounds
        codeLabel.text = stringCodeValue

        
        // Stop capturing and hence stop executing metadataOutput function over and over again
        captureSession?.stopRunning()
        
        // Call the function which performs navigation and pass the code string value we just detected
//        displayDetailsViewController(scannedCode: stringCodeValue)
        
    }
    
    func displayDetailsViewController(scannedCode: String) {
        let detailsViewController = DetailsViewController()
        detailsViewController.scannedCode = scannedCode
        //navigationController?.pushViewController(detailsViewController, animated: true)
        present(detailsViewController, animated: true, completion: nil)
    }

    //UITableView
    
    
    
}
