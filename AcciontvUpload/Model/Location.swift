//
//  Location.swift
//  AcciontvUpload
//
//  Created by 525 on 5/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import UIKit
import Photos

class LocationModel: NSObject {
    
    var id: Int?
    var address: String?
    var attributes: [String: [String: Int]] = [:]
    var city: String?
    var contact: [String: [String: Any]] = [:]
    var cost: Int?
    var costRange: Int?
    var county: String?
    var center: String = ""
    var category: String = ""
    var subcategory: String?
    var countryId: Int?
    var unit: String?
    var name: String?
    var postalCode: String?
    var serverId: Int?
    var photoPath: String?
    var status: LocationStatus = .Offline
    var state: String?
    var thumbnail: UIImage?
    var rowId: Int64?
    
    var assets: [PHAsset] = []
    var contacts: [ContactModel] = []
    var otherContacts: [ContactModel] = []
    var productions: [ProductionModel] = []
    var contactIndex: Int?
    var numberOfPics: Int?
    
    // Extra Info Data
    var descriptionLoc: String?
    var schedule: String?
    var availableFrom: String?
    var availableTo: String?
    var type: String?
    var time: String?
    var ratetype: String?
    var currency: String?
    var rateFrom: Int?
    var rateTo: Int?
    var oTperHour: Int?
    var selectedParking: [String]?
    var parking: [String: [String: Any]] = [:]
    var personalVehiclesAvailability: Bool?
    var route: String?
    
    enum LocationStatus {
        case Uploaded
        case Offline
    }
    
    // Lists from JSON
    var allCenters: [[String: Any]] = []
    var centersList: [String] = []
    var statusList: [String] = []
    var categoryList: [String] = []
    var subcategoryList: [String] = []
    var allAttributes: [[String: Any]] = []
    var allCountries: [[String: Any]] = []
    var allCategories: [[String: Any]] = []
    var allSubcategories: [[String: Any]] = []
    var allProductions: [[String: Any]] = []
    var allStates: [[String: Any]] = []
    var allTypes: [[String: Any]] = []
    var allSchedules: [[String: Any]] = []
    var allShooting: [[String: Any]] = []
    var allParkings: [[String: Any]] = []
    var allRateTypes: [[String: Any]] = []
    var attributesList: [String] = []
    var stateList: [String] = []
    var countryList: [String] = []
    var productionList: [String] = []
    var optionsSchedule: [String] = []
    var typeList: [String] = []
    var shootingList: [String] = []
    var rateTypeList: [String] = []
    var currencyList: [String] = []
    var parkingList: [String] = []
}
