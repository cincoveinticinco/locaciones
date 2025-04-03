//
//  CameraViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 15/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import Photos
import BSImagePicker

class CameraViewController: UIViewController {
    
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var photoModeButton: UIButton!
    @IBOutlet weak var toggleCameraButton: UIButton!
    @IBOutlet weak var toggleFlashButton: UIButton!
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var selectPhotosButton: UIButton!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    var token: String?
    let cameraController = CameraController()
    var location: LocationModel = LocationModel()
    let reach = ReachabilityTwo()
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleCaptureButton()
        configureCameraController()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: - Actions
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        if cameraController.flashMode == .on {
            cameraController.flashMode = .off
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash Off Icon"), for: .normal)
        }
            
        else {
            cameraController.flashMode = .on
            toggleFlashButton.setImage(#imageLiteral(resourceName: "Flash On Icon"), for: .normal)
        }
    }
    
    @IBAction func switchCameras(_ sender: UIButton) {
        do {
            try cameraController.switchCameras()
        } catch {
            print(error)
        }
        
        switch cameraController.currentCameraPosition {
        case .some(.front):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Front Camera Icon"), for: .normal)
            
        case .some(.rear):
            toggleCameraButton.setImage(#imageLiteral(resourceName: "Rear Camera Icon"), for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func captureImage(_ sender: UIButton) {
        cameraController.captureImage {(image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
    
    
    @IBAction func selectPhotos(_ sender: UIButton) {
        let imagePicker = BSImagePickerViewController()
        
        imagePicker.takePhotos = true
        imagePicker.takePhotoIcon = #imageLiteral(resourceName: "Photo Camera Icon")
        imagePicker.navigationBar.barTintColor = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.albumButton.tintColor = UIColor.white
        imagePicker.cancelButton.tintColor = UIColor.white
        imagePicker.doneButton.tintColor = UIColor.white
        imagePicker.selectionCharacter = "✓"
        imagePicker.selectionFillColor = UIColor.white
        imagePicker.selectionStrokeColor = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.selectionShadowColor = UIColor.gray
        imagePicker.selectionTextAttributes[NSAttributedStringKey.foregroundColor] = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 3
            case (.compact, .compact): // iPhone5-6 landscape
                return 6
            case (.regular, .regular): // iPad portrait/landscape
                return 4
            default:
                return 3
            }
        }
        
        let button: UIButton = UIButton(type: UIButtonType.custom)
        //set image for button
        button.setImage(UIImage(named: "Flash On Icon"), for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: Selector(("fbButtonPressed")), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imagePicker.cancelButton = UIBarButtonItem(customView: button)
        
        bs_presentImagePickerController(imagePicker, animated: true,
            select: {
            (asset: PHAsset) -> Void in
            print("Selected: \(asset)")
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish: \(assets)")
            // If location was created get location id and Save row to DB
            // Then upload to S3 and Post to server
            // If no location update the row
            self.getAssetUrl(mPhasset: assets.first!, completionHandler: {
                (responseURL: URL?) in
                let url = responseURL!
                self.resizeAsset(mPhassets: assets, completionHandler: { (mPhassets:[PHAsset]) in
                    if self.location.id != nil {
                        if LocationData.data.addPhoto(path: url.absoluteString, locationId: self.location.id!) != nil {
                            let AWS = S3(accessKey: "",
                                         secretKey: "",
                                         identityPool: "",
                                         bucketName: "locationaction-min",
                                         assets: mPhassets,
                                         locId: self.location.id!,
                                         token: self.token!)
                            print("Preparando para subir")
                            AWS.configureS3()
                            self.location.status = .Uploaded
                        }
                    }
                    self.location.assets = mPhassets
                })
                self.location.photoPath = url.absoluteString
                print(url)
                print(" ")
                
            })
            self.performSegue(withIdentifier: "Locations", sender: self)
            
            
        }, completion: nil)
    }
    
    
}


// MARK: - Extra Functionality
extension CameraViewController {
    func configureCameraController() {
        cameraController.prepare {(error) in
            if let error = error {
                print(error)
            }
            
            try? self.cameraController.displayPreview(on: self.cameraPreviewView)
        }
    }
    
    func styleCaptureButton() {
        captureButton.layer.borderColor = UIColor.black.cgColor
        captureButton.layer.borderWidth = 2
        
        captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func resizeAsset(mPhassets: [PHAsset], completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        var newAssets = [PHAsset]()
        for asset in mPhassets {
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            
            // Request resized image
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .aspectFit, options: options, resultHandler: { (image, _) -> Void in
                newAssets.append(asset)
            })
        }
        completionHandler(newAssets)
    }
    
    func getAssetUrl(mPhasset : PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput: PHContentEditingInput?, info: [AnyHashable: Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl : URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
        
    }
}
