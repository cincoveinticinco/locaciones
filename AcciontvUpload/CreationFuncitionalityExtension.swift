//
//  CreationFuncitionalityExtension.swift
//  AcciontvUpload
//
//  Created by 525 on 28/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Photos

extension CreationViewController: UIGestureRecognizerDelegate {
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/255.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: selectionTableView))! {
            return false
        }
        return true
    }
    func adjustHeightOfTableView(_ tableView: UITableView) {
        let height: CGFloat = tableView.contentSize.height;
        
        UIView.animate(withDuration: 0.5, animations: {
            if tableView.isEqual(self.contactsTableView) {
                self.contactsTableViewHeightConstraint.constant = height
            } else if tableView.isEqual(self.attributesTableView){
                self.attributesTableViewHeightConstraint.constant = height;
            } else if tableView.isEqual(self.productionTableView){
                self.productionsTableViewHeightConstraint.constant = height;
            } else if tableView.isEqual(self.selectionTableView) {
                self.selectionTableViewHeightConstraint.constant = height
            }
            
            self.view.setNeedsUpdateConstraints()
        })
    }
    
    func getSubcategoriesByCategory(category: String) -> [String] {
        location.subcategoryList = []
        for cat in location.allSubcategories {
            if preferredLanguage.contains("es") {
                if (cat["name_category_ESP"] as! String) == category {
                    location.subcategoryList.append(cat["name_ESP"] as! String)
                }
            } else {
                if (cat["name_category_ENG"] as! String) == category {
                    location.subcategoryList.append(cat["name_ENG"] as! String)
                }
            }
        }
        
        return location.subcategoryList
    }
    
  
    
    func getStatesByCountryId(countryId: Int){
        location.stateList = []
        for state in location.allStates {
            if (state["country_id"] as! Int) == countryId && preferredLanguage.contains("es"){
                location.stateList.append(state["name"] as! String)
            } else if (state["country_id"] as! Int) == countryId && preferredLanguage.contains("en") {
                location.stateList.append(state["nameAB"] as! String)
            }
        }
        
        
    }
    
    func getIdFor(list: [[String: Any]], withString string: String?) -> Int? {
        if string == nil {
            return nil
        }
        for item in list {
            if preferredLanguage.contains("es") {
                let name = item["name_ESP"] as? String
                if name?.caseInsensitiveCompare(string!) == ComparisonResult.orderedSame {
                    return item["id"] as? Int
                }
            } else {
                let name = item["name_ENG"] as? String
                if name?.caseInsensitiveCompare(string!) == ComparisonResult.orderedSame {
                    return item["id"] as? Int
                }
            }
        }
        return nil
    }
    
    func getIdForProduction(list: [[String: Any]], withString string: String?) -> Int? {
        if string == nil {
            return nil
        }
        for item in list {
            if item["production_name"] as? String == string {
                return item["id"] as? Int
            }
        }
        return nil
    }
    
    func getIdForState(list: [[String: Any]], withString string: String?) -> Int? {
        for item in list {
            if item["nameAB"] as? String == string {
                return item["id"] as? Int
            }
        }
        return nil
    }
    
    func getIdForRate(list: [[String: Any]], withString string: String?) -> Int? {
        for item in list {
            if item["rate"] as? String == string {
                return item["id"] as? Int
            }
        }
        return nil
    }
    
    func getIdByName(list: [[String: Any]], withString string: String?) -> Int? {
        for item in list {
            if item["name"] as? String == string {
                return item["id"] as? Int
            }
        }
        return nil
    }
    
    func getProdCenterIdByName(withString string: String?) -> Int? {
        
        for item in location.allCenters {
            if preferredLanguage.contains("es") {
                let name = item["prod_center_name_ESP"] as? String
                if name?.caseInsensitiveCompare(string!) == ComparisonResult.orderedSame {
                    return item["id"] as? Int
                }
            } else {
                let name = item["prod_center_name_ENG"] as? String
                if name?.caseInsensitiveCompare(string!) == ComparisonResult.orderedSame {
                    return item["id"] as? Int
                }
            }
        }
        return nil
    }
    
    func resizeAsset(mPhassets: [PHAsset], completionHandler: @escaping ((_ assets: [PHAsset]) -> Void)) {
        var newAssets = [PHAsset]()
        for asset in mPhassets {
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.resizeMode = .fast
            options.deliveryMode = .highQualityFormat
            
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
    
    func readJSONDataFromDisk() -> Data? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("info_location.json").path
        if FileManager.default.fileExists(atPath: filePath), let data = FileManager.default.contents(atPath: filePath) {
            return data
        }
        return nil
    }
    
    
    
    func saveDataFromJSON(json: JSON) {
        self.location.allCenters = json["prod_centers"].arrayValue.map {$0.dictionaryObject!}
        self.location.centersList = json["prod_centers"].arrayValue.map {$0["prod_center_name_ENG"].stringValue}
        self.location.statusList = json["prod_centers"].arrayValue.map {$0["status"].stringValue}
        self.location.categoryList = json["categories"].arrayValue.map {$0["name_ENG"].stringValue}
        self.location.allAttributes = json["attributes"].arrayValue.map {$0.dictionaryObject!}
        self.location.allCategories = json["categories"].arrayValue.map {$0.dictionaryObject!}
        self.location.allSubcategories = json["subcategories"].arrayValue.map {$0.dictionaryObject!}
        self.location.allCountries = json["countries"].arrayValue.map {$0.dictionaryObject!}
        self.location.allProductions = json["productions"].arrayValue.map {$0.dictionaryObject!}
        self.location.attributesList = json["attributes"].arrayValue.map {$0["name_ENG"].stringValue}
        self.location.stateList = json["states"].arrayValue.map {$0["nameAB"].stringValue}
        self.location.countryList = json["countries"].arrayValue.map {$0["name"].stringValue}
        self.location.productionList = json["productions"].arrayValue.map {$0["production_name"].stringValue}
        self.location.optionsSchedule = json["options_schedule"].arrayValue.map {$0["name"].stringValue}
        self.location.typeList = json["exterior_interior"].arrayValue.map {$0["name"].stringValue}
        self.location.shootingList = json["shooting"].arrayValue.map {$0["name"].stringValue}
        self.location.rateTypeList = json["type_rate"].arrayValue.map {$0["rate"].stringValue}
        self.location.currencyList = json["currencies"].arrayValue.map {$0["initials"].stringValue}
        self.location.parkingList = json["parking"].arrayValue.map {$0["name"].stringValue}
        self.location.allStates = json["states"].arrayValue.map {$0.dictionaryObject!}
        self.location.allTypes = json["exterior_interior"].arrayValue.map {$0.dictionaryObject!}
        self.location.allShooting = json["shooting"].arrayValue.map {$0.dictionaryObject!}
        self.location.allRateTypes = json["type_rate"].arrayValue.map {$0.dictionaryObject!}
        self.location.allSchedules = json["options_schedule"].arrayValue.map {$0.dictionaryObject!}
        self.location.allParkings = json["parking"].arrayValue.map {$0.dictionaryObject!}

        if self.preferredLanguage.contains("es") {
            self.location.centersList = json["prod_centers"].arrayValue.map {$0["prod_center_name_ESP"].stringValue}
            self.location.categoryList = json["categories"].arrayValue.map {$0["name_ESP"].stringValue}
            self.location.attributesList = json["attributes"].arrayValue.map {$0["name_ESP"].stringValue}
            self.location.stateList = json["states"].arrayValue.map {$0["name"].stringValue}
        }
        
        activeTextField = centerTextField
        DispatchQueue.main.async {
            self.listPickerView.selectRow(0, inComponent: 0, animated: true)
            self.currentData = self.location.centersList
            self.centerTextField.text = self.currentData[0]
            self.countryTextField.text = "United States"
            self.stateTextField.text = "Florida"
            self.getStatesByCountryId(countryId: 1)
        }
    }
    
    func createRequestParameters() -> [Any] {
        var request = URLRequest(url: URL(string: UrlsViewController.process_location)!)
        request.httpMethod = "POST"
        
        var params = ["session_id": self.token!,
                      "location_status_id": 1
            ] as [String : Any]
        if let address = locationAddressTextField.text {
            params.updateValue(address, forKey: "address")
            location.address = address
        }
        
        var counter = 0
        for attribute in selectedAttributes {
            if let attributeId = getIdFor(list: location.allAttributes, withString: attribute) {
                location.attributes.updateValue(["id_attribute": attributeId], forKey: "\(counter)")
                print("setted attribute Id \(attributeId)  \(attribute)")
            }
            counter+=1
        }
        
        if !location.attributes.isEmpty {
            params.updateValue(location.attributes, forKey: "location_attributes")
        }
        
        if let categoryId = getIdFor(list: location.allCategories, withString: selectedCategory.first) {
            params.updateValue(categoryId, forKey: "location_category_id")
            print("setted category Id \(categoryId)")
        }
        
        if let city = cityTextField.text {
            params.updateValue(city, forKey: "city")
            location.city = city
        }
        
        counter = 0
        for contact in location.contacts {
            var typeId = 2
            if index(ofAccessibilityElement: contact) == 0 {typeId = 1}
            location.contact.updateValue(["location_contact_type_id": typeId,
                                          "first_name": contact.firstName,
                                          "last_name": contact.lastName,
                                          "primary_phone_number": contact.primaryPhone,
                                          "other_phone_number": contact.otherPhone,
                                          "email": contact.email
                ], forKey: "\(counter)")
            counter+=1
            
        }
        for contact in location.otherContacts {
            location.contact.updateValue(["location_contact_type_id": 3,
                                          "first_name": contact.firstName,
                                          "last_name": contact.lastName,
                                          "primary_phone_number": contact.primaryPhone,
                                          "other_phone_number": contact.otherPhone,
                                          "email": contact.email,
                                          "type": contact.type
                ], forKey: "\(counter)")
        }
        
        if !location.contact.isEmpty {
            print("adding location contact   location_contacts")
            params.updateValue(location.contact, forKey: "location_contacts")
        }
        
        if let county = countyTextField.text {
            params.updateValue(county, forKey: "county")
            location.county = county
        }
        
        if let centerId = getProdCenterIdByName(withString: centerTextField.text) {
            print("CENTER ID")
            print(centerId)
            params.updateValue(centerId, forKey: "prod_center_id")
        }
        
        if let name = locationNameTextField.text {
            params.updateValue(name, forKey: "name")
            location.name = name
        }
        
        if let postalCode = postalCodeTextField.text {
            params.updateValue(postalCode, forKey: "postal_code")
            location.postalCode = postalCode
        }
        
        if let unit = unitTextField.text {
            params.updateValue(unit, forKey: "unit")
            location.unit = unit
        }
        
        if let subCategoryId = getIdFor(list: location.allSubcategories, withString: selectedSubcategory.first) {
            params.updateValue(subCategoryId, forKey: "location_subcategory_id")
            print("setted subcategory Id \(subCategoryId)")
        }
        
        if let stateId = getIdForState(list: location.allStates, withString: stateTextField.text) {
            params.updateValue(stateId, forKey: "state_id")
            print("setted state Id \(stateId)")
            location.state = stateTextField.text
        }
        
        // Extra information
        if let description = self.location.descriptionLoc {
            params.updateValue(description, forKey: "description")
        }
        
        if let scheduleId = getIdByName(list: location.allSchedules, withString: location.schedule) {
            params.updateValue(scheduleId, forKey: "option_schedule_id")
        }
        
        if let availableFrom = self.location.availableFrom {
            params.updateValue(availableFrom, forKey: "operation_from")
        }
        
        if let availableTo = self.location.availableTo {
            params.updateValue(availableTo, forKey: "operation_to")
        }
        
        if let locationExteriorId = getIdByName(list: location.allShooting, withString: location.time) {
            params.updateValue(locationExteriorId, forKey: "location_exterior_interior_id")
        }
        
        if let locationShootingId = getIdByName(list: location.allTypes, withString: location.type) {
            params.updateValue(locationShootingId, forKey: "location_shooting_id")
        }
        
        if let locationRateTypeId = getIdForRate(list: location.allRateTypes, withString: location.ratetype) {
            params.updateValue(locationRateTypeId, forKey: "type_rate_id")
        }
        
        if let currency = location.currency {
            if (currency.localizedCaseInsensitiveContains("MXN")) {
                params.updateValue(2, forKey: "currency_id")
            } else if (currency.localizedCaseInsensitiveContains("USD")) {
                params.updateValue(1, forKey: "currency_id")
            } else {
                params.updateValue(3, forKey: "currencyt_id")
            }
        }
        
        if let rateFrom = location.rateFrom {
            params.updateValue(Int(rateFrom), forKey: "cost")
        }
        
        if let rateTo = location.rateTo {
            params.updateValue(Int(rateTo), forKey: "cost_range")
        }
        
        if let overTimeCost = location.oTperHour {
            params.updateValue(overTimeCost, forKey: "over_time_cost")
        }
        
        if let selectedParkings = location.selectedParking {
            counter = 0
            for parking in selectedParkings {
                if let idParking = getIdByName(list: location.allParkings, withString: parking) {
                    location.parking.updateValue(["id_parking": idParking,
                                                  ], forKey: "\(counter)")
                    counter+=1
                }
                
            }
        }
        
        if !location.parking.isEmpty {
            params.updateValue(location.contact, forKey: "location_parkings")
        }
        
        
        if let vehicleAvailable = location.personalVehiclesAvailability {
            params.updateValue(vehicleAvailable, forKey: "parking_truckCrew")
        }
        
        if let routeDetail = location.route {
            params.updateValue(routeDetail, forKey: "route_detail")
        }
        
        return [request, params]
    }
    
}

extension UIImage {
    
    func imageResize (sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
}

extension UIViewController {
    
    @objc func adjustTextField(_ textField: UITextField, scrollView: UIScrollView) {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: scrollView)
        print(pointInTable)
        var contentOffset:CGPoint = scrollView.contentOffset
        contentOffset.y  = CGFloat(pointInTable.y) - CGFloat(200.0)
        print(contentOffset)
        if let accessoryView = textField.inputAccessoryView {
            print("accessotry view frame size heigt")
            print(accessoryView.frame.size.height)
            contentOffset.y -= accessoryView.frame.size.height
        }
        scrollView.contentOffset = contentOffset
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    struct UrlsViewController {
        static let process_location =  UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.ServerURL)! + "/location_modules/process_location"
    }
}


extension UIViewController {
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
