//
//  Request.swift
//  AcciontvUpload
//
//  Created by 525 on 5/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import SwiftyJSON


class AccionRequest {
    
    let requestType: String
    var parameters: [String : Any]
    let url: URL
    public let server =   UserDefaults.standard.string(forKey: "server_url")!
    
    public init(_ requestType: String, _ parameters: [String : Any], _ endpoint: String) {
        self.requestType = requestType
        self.parameters = parameters
        self.url = URL(string: server + endpoint)!
    }
    
    func setupRequest() -> URLRequest {
        var request = URLRequest(url: self.url)
        request.httpMethod = self.requestType
        
        let jsonData = try? JSONSerialization.data(withJSONObject: self.parameters, options: [])
        request.httpBody = jsonData
        request.addValue(AccionKey.HTTPContent.JSONType, forHTTPHeaderField: AccionKey.HTTPContent.Header)
        print(self.parameters)
        return request
    }
    
    func fetchInfoLocation(request: URLRequest) -> JSON {
        var json = JSON(arrayLiteral: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                print("CREATING -> info_location.json ")
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsURL.appendingPathComponent("view_locations.json")
                try data.write(to: fileURL, options: .atomic)
            } catch { }
            
            
            json = try! JSON(data: data)
            
        }
        task.resume()
        return json
    }
    
    func fetchData(request: URLRequest, completionHander: @escaping (_ response: JSON) -> Void) {
        print("Now Fetching..")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("creating task")
            guard let data = data, error == nil else {
                print(error!)
                //completionHander(JSON.null)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                print(AccionKey.BadResponse + "\(httpStatus.statusCode)")
                print(response!)
                print(String(data: data, encoding: String.Encoding.utf8)!)
                completionHander(JSON.null)
            } else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                //                do {
                //                    print("CREATING -> production.json ")
                //                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                //                    let fileURL = documentsURL.appendingPathComponent("list_productions" + self.JSONExtension)
                //                    try data.write(to: fileURL, options: .atomic)
                //                } catch {
                //                    print(error)
                //                }
                print("creating JSON")
                let json = try! JSON(data: data)
                completionHander(json)
            }
        }
        task.resume()
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix(AccionRequest.AccionKey.Image),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension AccionRequest {
    struct AccionKey {
        static let Year = "filter_year"
        static let Centers = "production_center"
        static let Continuities = "continuities"
        static let Elements = "elements"
        static let Types = "production_types"
        static let Subtypes = "production_subtypes"
        static let Productions = "productions"
        static let Status = "status"
        static let Session = "session_id"
        static let Image = "image"
        static let BadResponse = "statusCode should be 200, but is "
        struct HTTPContent {
            static let JSONType = "application/json"
            static let Header = "Content-Type"
        }
    }
}
