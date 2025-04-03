//
//  s3Controller.swift
//  AcciontvUpload
//
//  Created by 525 on 18/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore
import Photos
import SwiftyJSON

// MARK: - S3 Definition

class S3 {
    
    private var accessKey: String?
    private var secretKey: String?
    private var identityPool: String?
    private var S3BucketName: String?
    private var assets: [PHAsset]?
    private var locationId: Int?
    private var token: String?
    private var localName: String?
    private var firstPhotoName: String?
    
    init(accessKey: String, secretKey: String, identityPool: String, bucketName: String, assets: [PHAsset], locId: Int, token: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.identityPool = identityPool
        self.S3BucketName = bucketName
        self.assets = assets
        self.locationId = locId
        self.token = token
    }
    
    // MARK: - Configuration
    
    func configureS3() {
        print("Aqui estoiy en es S3")
        
        var localFileName: String?
        var data: Data?
        
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        var targetSize = CGSize()
        
        for (index, assetImage) in assets!.enumerated() {
            if assetImage.pixelHeight == assetImage.pixelWidth {
                targetSize = CGSize(width: 1024.0, height: 1024.0)
            } else if (assetImage.pixelHeight) > (assetImage.pixelWidth) {
                targetSize = CGSize(width: 768.0, height: 1024.0)
            } else {
                targetSize = CGSize(width: 1024.0, height: 768.0)
            }
            print(targetSize)
            
            PHImageManager.default().requestImage(for: (assetImage), targetSize: targetSize , contentMode: .aspectFill, options: options) { (image, array) in
                localFileName = assetImage.value(forKey: "filename") as? String
                
                
                
                /*var extensionFile = String(localFileName!.dropFirst(localFileName!.endIndex.encodedOffset - 3))*/
                
                var extensionFile = localFileName?.fileExtension()
                let nameFile = localFileName?.fileName()
                
                print("Extension -> \(String(describing: extensionFile)) for file -> \(localFileName!)\n")
                
                //extensionFile = "." + extensionFile!
                extensionFile = extensionFile == "HEIC" ? ".jpg" : "." + extensionFile!
                
                localFileName = String(localFileName!.dropLast(3))
                localFileName = nameFile! + extensionFile!
                data = UIImageJPEGRepresentation(image!, 0.9)
            }
            if index == 0 {
                firstPhotoName = localFileName
            }
            
            if localFileName == nil {
                return
            }
            print("             Local File Name:    \(localFileName!)")
            let remoteName = "\(Date().hashValue)_" + localFileName!
            /*
            AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
            AWSDDLog.sharedInstance.logLevel = .verbose
            
            
            let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: identityPool!)
            
            
            let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            
            
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()!
            uploadRequest.body = generateImageUrl(fileName: remoteName, data: data) as URL //selectedImageURL!
            uploadRequest.key = remoteName
            uploadRequest.bucket = S3BucketName
            uploadRequest.contentType = "image/jpg"
            
            print("\n\nuploadRequest?.body      \(uploadRequest.body)")
            print("uploadRequest?.key      \(uploadRequest.key!) \n\n")
            let transferManager = AWSS3TransferManager.default()
            // s3.amazonaws.com
             
            */
            localName = localFileName!
            _ = generateImageUrl(fileName: remoteName, data: data!)
            
            uploadFile(dataConfig: data!, remoteName: remoteName, onSuccess: {
                urlUpload in
                self.createImages(for: remoteName, withLocationId: self.locationId!)
                self.remoteImageWithUrl(fileName: remoteName)
                
            }, onFailure: {
                error in
                    print(error)
            })
            
            //performFileUpload(withTransferManager: transferManager, request: uploadRequest)
        }
    }
    
    func sendRequest(route:String, params: NSMutableDictionary,  onSuccess: @escaping(JSON) -> Void, onFailure: @escaping(Error) -> Void){
            
            let url : String = route;
            let request: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: url)! as URL);
            request.httpMethod = "POST";
            
            var headers = request.allHTTPHeaderFields ?? [:]
            headers["Content-Type"] = "application/json"
            request.allHTTPHeaderFields = headers
            
            params.addEntries(from: ["session_id" : token!])
            
            print(params)
            print(url)
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options:[]);
            
            let session = URLSession.shared;
            let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                if(error != nil){
                    onFailure(error!)
                }else{
                    var result: Any
                    if let returnData = String(data: data!, encoding: .utf8) {
                        if(route == "/app_release/assignment/"){
                            print(returnData)
                        }
                            
                    }
                    do {
                        result = try JSON(data: data!)
                        onSuccess(result as! JSON);
                    } catch {
                        print("ERROR REQUEST", error)
                        
                    }
                }
            })
            
            task.resume();
        }
    
    
    func getPutSignUrl(filename: String, folder: String, onSuccess: @escaping(String) -> Void, onFailure: @escaping(String) -> Void){
            let params: NSMutableDictionary = [
                "filename": filename,
                "bucket": folder,
           ];
        
        print("getPutSignUrl params", params)
           
        self.sendRequest(route: Urls.signImage, params: params, onSuccess:
               {
                   json in
                   DispatchQueue.main.sync {
                       onSuccess(json["url"].stringValue)
                   }
                   
           }, onFailure: {
               error in
               print(error.localizedDescription);
               onFailure(error.localizedDescription)
           }
           )
        }
    
    func uploadFile(dataConfig: Data, remoteName: String, onSuccess: @escaping(String) -> Void, onFailure: @escaping(Error) -> Void) -> Void{
            
            print("uploadFile - remoteName ", remoteName)
           
            
            self.getPutSignUrl(filename: remoteName, folder: S3BucketName!, onSuccess: {
                url in
                print("SIGN URL", url)
                self.uploadImage(urlSign: url, image: dataConfig ){
                    success, error in
                    print("SUCCESS", success)
                    print("ERROR", error)
                    if(success){
                        print("https://s3.amazonaws.com/\(self.S3BucketName!)/\(remoteName)")
                       let s3URL = URL(string: "https://s3.amazonaws.com/\(self.S3BucketName!)/\(remoteName)")
                       dump(s3URL)
                       onSuccess("https://s3.amazonaws.com/\(self.S3BucketName!)/\(remoteName)");
                    }else{
                        onSuccess("fail_s3");
                        print("Empty result")
                    }
                    
                }
            }, onFailure: {
                error in
            })
        }
    
    func uploadImage(urlSign: String, image: Data, completion: @escaping(_ isComplete: Bool, _ error: Error?) -> ()){
              
             guard let validURL = URL(string: urlSign) else {
                  print("URL creatinn failed")
                  return
              }
              
              let config = URLSessionConfiguration.default
              config.waitsForConnectivity = true;
              config.timeoutIntervalForResource = 60*5
              
              var request = URLRequest(url: validURL)
              let boundary = "Boundary-\(UUID().uuidString)"
              request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
              
              request.httpMethod = "PUT";
              
              let httpBody = NSMutableData()
              
              if !image.isEmpty{
                  let mimeType = self.mimeType(for: image)
                  let extensionData = self.extensionData(for: image)
                  print("MIME", mimeType)
                  httpBody.append(convertFileData(
                                      fieldName: "img",
                                      fileName: "image\(extensionData)",
                                      mimeType: mimeType,
                                      fileData: image,
                                      using: boundary))
              }
              
              

              httpBody.append(Data("--\(boundary)--".utf8))
              request.httpBody = httpBody as Data
              
               URLSession(configuration: config).dataTask(with: request as URLRequest){
                  (data, response, error) in
                  
                  if let httpresponse = response as? HTTPURLResponse {
                      print("API response status create image: \(httpresponse.statusCode)")
                      if httpresponse.statusCode == 403 {
                          let error = NSError(domain: "Forbiden Error", code: 403, userInfo: nil)
                          completion(false, error)
                          return
                      }

                      if httpresponse.statusCode == 404 {
                          let error = NSError(domain: "Not Found Error", code: 404, userInfo: nil)
                          completion(false, error)
                          return
                      }

                      if httpresponse.statusCode == 500 {
                          let error = NSError(domain: "Server Error", code: 500, userInfo: nil)
                          completion(false, error)
                          return
                      }
                  }
                  
                  if let error = error {
                      print("Error on upload", error)
                      completion(false, error)
                      return
                  }
                  
                  guard let data = data else{
                      let error = NSError(domain: "Network unavailable", code: 101, userInfo: nil)
                      completion(false, error)
                      return
                  }
                   
                   print(data)
                 completion(true, nil)
                  
                  
              }.resume()
              
          }
    
    private func mimeType(for data: Data) -> String {

              var b: UInt8 = 0
              data.copyBytes(to: &b, count: 1)

              switch b {
              case 0xFF:
                  return "image/jpeg"
              case 0x89:
                  return "image/png"
              case 0x47:
                  return "image/gif"
              case 0x4D, 0x49:
                  return "image/tiff"
              case 0x25:
                  return "application/pdf"
              case 0xD0:
                  return "application/vnd"
              case 0x46:
                  return "text/plain"
              default:
                  return "application/octet-stream"
              }
          }
          
          private func extensionData(for data: Data) -> String {

              var b: UInt8 = 0
              data.copyBytes(to: &b, count: 1)

              switch b {
              case 0xFF:
                  return ".jpeg"
              case 0x89:
                  return ".png"
              case 0x47:
                  return ".gif"
              case 0x4D, 0x49:
                  return ".tiff"
              case 0x25:
                  return ".pdf"
              case 0xD0:
                  return ".vnd"
              case 0x46:
                  return ".txt"
              default:
                  return ""
              }
          }
          
          func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
            let data = NSMutableData()

            //data.append(Data("--\(boundary)\r\n".utf8))
            //data.append(Data("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".utf8))
            //data.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
            data.append(fileData)
            //data.append(Data("\r\n".utf8))

            return data as Data
          }
          
    
    func performFileUpload(withTransferManager manager: AWSS3TransferManager, request: AWSS3TransferManagerUploadRequest) {
        manager.upload(request).continueWith(block: { (task) -> AnyObject? in
            
            DispatchQueue.main.async {
                //
            }
            
            if let error = task.error {
                print("Upload failed with error: (\(error.localizedDescription))")
            }

            if task.result != nil {
                
                self.createImages(for: request.key!, withLocationId: self.locationId!)
                let s3URL = URL(string: "https://s3.amazonaws.com/\(self.S3BucketName!)/\(request.key!)")
                print("    Uploaded to:\n\(s3URL!)")
                // Remove locally stored file
                self.remoteImageWithUrl(fileName: request.key!)
                
                DispatchQueue.main.async() {
                    print("uploaded")
                }
            
            }
            else {
                print("Unexpected empty result.")
            }
            return nil
        })
    }
        
    func generateImageUrl(fileName: String, data: Data?) -> URL {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        let data = data
        
        let fileManager = FileManager.default
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(localName!)
        print("\n path: \(localName!)")
        let image = UIImage(data: data!)
        print(paths)
        let imageData = UIImageJPEGRepresentation(image!, 0.9)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        
        do {
            try data!.write(to: fileURL, options: [.atomicWrite])
        } catch {
            print("Error while generation image -------------> \(error)")
        }
        
        return fileURL
    }
    
    
    func remoteImageWithUrl(fileName: String) {
        let fileURL = NSURL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        do {
            try FileManager.default.removeItem(at: fileURL as URL)
        } catch {
            print(error)
        }
    }
    
    func createImages(for image: String, withLocationId locationId: Int){
        var request = URLRequest(url: URL(string: Urls.create)!)
        request.httpMethod = "POST"
        var cover = 0
        if image.range(of:firstPhotoName!) != nil {
            cover = 1
        }
        let params = ["session_id": token!,
                      "id_location": locationId,
                      "comment": "",
                      "location_images": ["0": ["cover": cover, "route": image]]
            ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("     -- ----      ---- --")
        print("     -- ----    CREATING IMAGES  ---- --")
        print(String(data: jsonData!, encoding: .utf8)!)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error!)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(httpStatus)")
            }
            
            let json = try! JSON(data: data)
            print(json)
        }
        task.resume()
    }
    
    struct Urls {
        static let create =  UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.ServerURL)! + "/location_modules/create_images"
        static let signImage =  UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.ServerURL)! + "/continuities/getPresignedUrlService"
    }
}



extension String{
    func fileName() -> String{
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String{
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
}
