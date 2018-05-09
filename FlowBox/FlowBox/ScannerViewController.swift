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

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var PreviewView: UIView!
    var captureDevice:AVCaptureDevice?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var captureSession:AVCaptureSession?
    let headerSize = 205.0
    let height = 305.0
    var isHidden = false

    var products = [String]()
    var prodCount = [String : Int]()

    
    var prices = [String : Double]()
    var names = [String : String]()

    var totalCost = 0.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func didPressToScan(_ sender: Any) {
        // Calculate new frame size for the table header
        var newRect = tableView.frame
        newRect.origin.y = CGFloat(!isHidden ? 60 : headerSize);
        newRect.size.height = CGFloat(!isHidden ? headerSize : 0) + CGFloat(height-55)

        // Get the reference to the header view
        // Animate the height change
        UIView.animate(withDuration: 0.6, animations: { () -> Void in
            self.isHidden = !self.isHidden
            if(self.isHidden) {
                self.captureSession?.stopRunning()
            }else {
                self.captureSession?.startRunning()
            }
            self.tableView.frame = newRect
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Registro
        prices["3700123302360"] = 1.0
        names["3700123302360"] = "Agua M. Nestle S.Gas"
        
        prices["7908066400075"] = 3.55
        names["7908066400075"] = "Chips Batata Mais Pura"

        

        
        
        
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
        print(stringCodeValue)
        
        // Stop capturing and hence stop executing metadataOutput function over and over again
        if let v = prices[stringCodeValue] {
            
            self.captureSession?.stopRunning()
            
            totalCost = totalCost + v;
            
            let alert = UIAlertController(title: "Adicionado ao Carrinho", message: names[stringCodeValue], preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.captureSession?.startRunning()
            }))
            
            self.present(alert, animated: true, completion: nil)
            
            
            if let _ = prodCount[stringCodeValue] {
                prodCount[stringCodeValue] = prodCount[stringCodeValue]! + 1
            }else {
                products.append(stringCodeValue)
                prodCount[stringCodeValue] = 1
            }
        }
        
        self.tableView.reloadData()
    }
    
    func displayDetailsViewController(scannedCode: String) {
        let detailsViewController = DetailsViewController()
        detailsViewController.scannedCode = scannedCode
        //navigationController?.pushViewController(detailsViewController, animated: true)
        present(detailsViewController, animated: true, completion: nil)
    }

    //UITableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0 ) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "total", for: indexPath) as! TotalCell
            cell.setPrice(cents: Double(totalCost))
            return cell
        }
        
        var product = products[indexPath.row-1]

        let cell = tableView.dequeueReusableCell(withIdentifier: "item", for: indexPath) as! ProductCell
        
        cell.setCell(name: names[product]!, count: prodCount[product]!,
                     cents: Double(Float(prodCount[product]!) * Float(prices[product]!)))
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + products.count
    }
    
}
