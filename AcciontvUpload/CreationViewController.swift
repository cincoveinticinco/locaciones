//
//  ViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 29/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftValidator
import SQLite
import TaskQueue
import Reachability
import BSImagePicker
import Photos
import SwipeCellKit

class CreationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, ValidationDelegate {

    @IBOutlet weak var centerTextField: UITextField!
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var subcategoryTableView: UITableView!
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var productionTableView: UITableView!
    @IBOutlet weak var attributesTableView: UITableView!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var countyTextField: UITextField!
    //@IBOutlet weak var newContactButton: UIButton!
    @IBOutlet weak var contactsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationAddressTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var productionsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attributesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var subcategoryTableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var subCategoryLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addMoreInfoButton: UIButton!
    @IBOutlet weak var createLocationButton: UIButton!
    @IBOutlet weak var addAttributesButton: UIButton!
    @IBOutlet weak var addProductionButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var primaryPhoneTextField: UITextField!
    @IBOutlet weak var otherPhoneTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField!
    
    var location: LocationModel = LocationModel()
    var contact: ContactModel = ContactModel()
    var token: String?
    var user: User?
    let serverURL = UserDefaults.standard.string(forKey: Identifier.Server)

    var selectedCategory: [String] = []
    var selectedSubcategory: [String] = []
    var selectedAttributes: [String] = []
    var selectedProduction: [String] = []
    var currentData: [String] = []
    
    var listDataCenter: [String] = []
    var listCountry: [String] = []
    var listState: [String] = []
    
    
    var activeTextField: UITextField!

    let listPickerView = UIPickerView()
    let preferredLanguage = NSLocale.preferredLanguages[0]
    
    let centerPickerView = UIPickerView()
    let countryPickerView = UIPickerView()
    let statePicerkView = UIPickerView()
    
    let validator = Validator()
    let reach = ReachabilityTwo()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationIcons()
        
        var json = JSON()
        // MARK: Request
        // Do the request if there's no info_location.json Locally
        if (readJSONDataFromDisk() != nil) {
            print(" -> info_location.json EXIST!!")
            json = JSON(readJSONDataFromDisk()!)
            saveDataFromJSON(json: json)
        } else {
            if ReachabilityTwo.isConnectedToNetwork() {
                print(" GETTING info_location from Server acciontv.com")
                
                var request = URLRequest(url: URL(string: "\(serverURL!)/location_modules/info_location")!)
                request.httpMethod = "POST"
                let postString = "session_id=\(token!)"
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("error=\(error!)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response!)")
                        self.performSegue(withIdentifier: Identifier.Login, sender: self)
                    } else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 200 {
                        json = try! JSON(data: data)
                        
                        // save locally
                        
                        do {
                            print("CREATING -> info_location.json ")
                            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let fileURL = documentsURL.appendingPathComponent("info_location.json")
                            try data.write(to: fileURL, options: .atomic)
                        } catch { }
                        
                        self.saveDataFromJSON(json: json)
                    }
                    
                }
                task.resume()
            } else {
                let alertController = UIAlertController(title: "Error", message: NSLocalizedString("Please connect to internet first. LOCATIONS needs to download some data before uploading locations.", comment: ""), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "unwindToMainMenuWithoutData", sender: self)
                    }
                })
                alertController.addAction(defaultAction)
                present(alertController, animated: true, completion: nil)
            }
            
            
//            let accionRequest = AccionRequest( "POST", [:], "info_location")
//            let req = accionRequest.setupRequest()
//            let json = accionRequest.fetchInfoLocation(request: req)
//            self.saveDataFromJSON(json: json)
        }
        
        
        
        // MARK: Initialization
        
        centerTextField.delegate = self
        locationNameTextField.delegate = self
        stateTextField.delegate = self
        countryTextField.delegate = self
        locationAddressTextField.delegate = self
        unitTextField.delegate = self
        countyTextField.delegate = self
        cityTextField.delegate = self
        postalCodeTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        primaryPhoneTextField.delegate = self
        otherPhoneTextField?.delegate = self
        emailTextField.delegate = self

        selectionTableView.delegate = self
        selectionTableView.dataSource = self
        subcategoryTableView.delegate = self
        subcategoryTableView.dataSource = self
        attributesTableView.delegate = self
        attributesTableView.dataSource = self
        contactsTableView.delegate =  self
        contactsTableView.dataSource = self
        productionTableView.delegate = self
        productionTableView.dataSource = self
        
        selectionTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        subcategoryTableView.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        attributesTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        contactsTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        productionTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        
        
        addMoreInfoButton.isEnabled = true
        createLocationButton.isEnabled = false
        stateTextField.isEnabled = true
        countyTextField.isEnabled = true
        cityTextField.isEnabled = true
        
        centerTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        locationNameTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        locationAddressTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        countryTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        stateTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        unitTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        countyTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        postalCodeTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        centerTextField.layer.borderWidth = 1.0
        locationNameTextField.layer.borderWidth = 1.0
        stateTextField.layer.borderWidth = 1.0
        countryTextField.layer.borderWidth = 1.0
        unitTextField.layer.borderWidth = 1.0
        countyTextField.layer.borderWidth = 1.0
        locationAddressTextField.layer.borderWidth = 1.0
        cityTextField.layer.borderWidth = 1.0
        postalCodeTextField.layer.borderWidth = 1.0
        addAttributesButton.layer.borderWidth = 1.0
        //newContactButton.layer.borderWidth = 1.0
        addProductionButton.layer.borderWidth = 1.0
        addMoreInfoButton.layer.borderWidth = 1.0
        createLocationButton.layer.borderWidth = 1.0
        firstNameTextField.layer.borderWidth = 1.0
        lastNameTextField.layer.borderWidth = 1.0
        primaryPhoneTextField.layer.borderWidth = 1.0
        otherPhoneTextField?.layer.borderWidth = 1.0
        emailTextField.layer.borderWidth = 1.0
        
        centerTextField.layer.borderColor = UIColor.lightGray.cgColor
        locationNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        stateTextField.layer.borderColor = UIColor.lightGray.cgColor
        countryTextField.layer.borderColor = UIColor.lightGray.cgColor
        unitTextField.layer.borderColor = UIColor.lightGray.cgColor
        countyTextField.layer.borderColor = UIColor.lightGray.cgColor
        locationAddressTextField.layer.borderColor = UIColor.lightGray.cgColor
        cityTextField.layer.borderColor = UIColor.lightGray.cgColor
        postalCodeTextField.layer.borderColor = UIColor.lightGray.cgColor
        addAttributesButton.layer.borderColor = UIColor.darkGray.cgColor
        //newContactButton.layer.borderColor = UIColor.darkGray.cgColor
        addProductionButton.layer.borderColor = UIColor.darkGray.cgColor
        addMoreInfoButton.layer.borderColor = UIColor.darkGray.cgColor
        createLocationButton.layer.borderColor = UIColor.darkGray.cgColor
        firstNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        primaryPhoneTextField.layer.borderColor = UIColor.lightGray.cgColor
        otherPhoneTextField?.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        centerTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        centerTextField.rightView?.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        centerTextField.rightView?.contentMode = .scaleAspectFit
        centerTextField.rightViewMode = .unlessEditing
        centerTextField.translatesAutoresizingMaskIntoConstraints = false
        centerTextField.rightView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        countryTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        countryTextField.rightView?.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        countryTextField.rightView?.contentMode = .scaleAspectFit
        countryTextField.rightViewMode = .unlessEditing
        countryTextField.translatesAutoresizingMaskIntoConstraints = false
        countryTextField.rightView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        stateTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        stateTextField.rightView?.frame = CGRect(x: 10, y: 0, width: 20, height: 20)
        stateTextField.rightView?.contentMode = .scaleAspectFit
        stateTextField.rightViewMode = .unlessEditing
        stateTextField.translatesAutoresizingMaskIntoConstraints = false
        stateTextField.rightView?.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        listDataCenter = location.centersList
        listCountry = location.countryList
        listState = location.stateList
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = CustomBackButton.createWithText(text: "", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), target: self, action: #selector(CreationViewController.goback(_:)))
        self.navigationItem.leftBarButtonItems = newBackButton
        
        selectionTableView.rowHeight = 30
        
        listPickerView.delegate = self
        listPickerView.dataSource = self
        
        centerPickerView.delegate = self;
        centerPickerView.dataSource = self;
        
        countryPickerView.delegate = self;
        countryPickerView.dataSource = self;
        
        statePicerkView.delegate = self;
        statePicerkView.dataSource = self;
        
        
        centerTextField.inputView = centerPickerView
        countryTextField.inputView = countryPickerView
        stateTextField.inputView = statePicerkView
        
        
        firstNameTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        primaryPhoneTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        otherPhoneTextField?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        createPickerToolBar()
        
        //validator.registerField(centerTextField, rules: [RequiredRule()])
        validator.registerField(postalCodeTextField, rules: [ZipCodeRule(regex: "[0-9]{0,5}")])
        validator.registerField(locationNameTextField, rules: [RequiredRule(), RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9\\.\\,\\_\\-\\–\\@\\#\\(\\)\\&]*$"), MaxLengthRule(length: 30) ])
        validator.registerField(locationAddressTextField, rules: [RequiredRule(), RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9\\.\\,\\_\\-\\–\\#\\(\\)\\&]*$")])
        validator.registerField(unitTextField, rules: [RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9\\.\\,\\_\\-\\–\\#\\(\\)\\&]*$")])
        //validator.registerField(stateTextField, rules: [RequiredRule()])
        validator.registerField(cityTextField, rules: [RequiredRule(), RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ ]*$"), MaxLengthRule(length: 30)])
        validator.registerField(countyTextField, rules: [RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ ]*$"), MaxLengthRule(length: 30)])
        validator.registerField(firstNameTextField, rules: [RequiredRule(),RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9]*$"), MaxLengthRule(length: 30)])
        validator.registerField(lastNameTextField, rules: [RequiredRule(), RegexRule(regex: "^[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9]*$"), MaxLengthRule(length: 30)])
        validator.registerField(primaryPhoneTextField, rules: [RequiredRule(), PhoneNumberRule()])
        //validator.registerField(otherPhoneTextField!, rules: [PhoneNumberRule()])
        //validator.registerField(emailTextField, rules: [EmailRule(), MaxLengthRule(length: 40)])
        
        self.hideKeyboardWhenTappedAround()
        
        LocationData.data.selectAll()
        LocationData.data.selectAllFromProductions()
        LocationData.data.selectAllFromPhotos()
        
        validator.validate(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("viewDidAppear")
        print(location.contacts)
        print(location.productions)
        self.adjustHeightOfTableView(attributesTableView)
        self.adjustHeightOfTableView(productionTableView)
        self.adjustHeightOfTableView(contactsTableView)
        self.adjustHeightOfTableView(selectionTableView)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        SelectionCell.selectionTitles[0] = "SELECT"
    }
    
    override func openMenu(_ sender: UIButton?) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "User Menu") as! UserMenuTableViewController
        popoverContent.user = self.user
        popoverContent.tableView.reloadData()
        popoverContent.modalPresentationStyle = .popover
        if let popover = popoverContent.popoverPresentationController {
            
            let viewForSource = sender! as UIView
            popover.sourceView = viewForSource
            popover.sourceRect = viewForSource.bounds
            popoverContent.preferredContentSize = CGSize(width: 270, height: 90)
            popover.delegate = self
        }
        
        self.present(popoverContent, animated: true, completion: nil)
    }

    // MARK: - Insert Data
    
    @IBAction func createLocationAction(_ sender: UIButton) {
        if emailTextField.text == "" || emailTextField.text == " " {
            validator.unregisterField(self.emailTextField)
        } else {
            validator.registerField(emailTextField, rules: [EmailRule(), MaxLengthRule(length: 40)])
        }
        if postalCodeTextField.text == "" || postalCodeTextField.text == " " {
            validator.unregisterField(self.postalCodeTextField)
        } else {
            validator.registerField(postalCodeTextField, rules: [ExactLengthRule(length: 5)])
        }
        if unitTextField.text == "" || unitTextField.text == " " {
            validator.unregisterField(self.unitTextField)
        } else {
            validator.registerField(unitTextField, rules: [RegexRule(regex: "[a-zA-ZÁáÀàÉéÈèÍíÌìÓóÒòÚúÙùÜüÑñ 0-9\\.\\,\\_\\-\\–\\#\\(\\)\\&]*$")])
        }
        if otherPhoneTextField?.text == "" || otherPhoneTextField?.text == " " {
            validator.unregisterField(self.otherPhoneTextField!)
        } else {
            validator.registerField(otherPhoneTextField!, rules: [PhoneNumberRule()])
        }
        validator.validate(self)
    }
    
    func validationSuccessful() {
        if validateAddress() {
            contact.firstName = firstNameTextField.text!
            contact.lastName = lastNameTextField.text!
            contact.primaryPhone = primaryPhoneTextField.text!
            contact.otherPhone = (otherPhoneTextField?.text)!
            contact.email = emailTextField.text!
            self.location.contacts.append(contact)
            
            createLocation()
            photolibrarySelected()
        } else {
            let alert = UIAlertController(title: NSLocalizedString("ALERT", comment: "") , message: NSLocalizedString("The address you typed already exists", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func validateAddress() -> Bool {
        if let _ = LocationData.data.getLocationByAddress(addressText: locationAddressTextField.text!) {
            return false
        }
        return true
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1).cgColor
                field.layer.borderWidth = 1.0
                field.leftView = UIImageView(image: #imageLiteral(resourceName: "Alert Icon"))
                field.leftView?.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1)
                field.leftView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                field.leftView?.contentMode = .scaleAspectFit
                field.leftViewMode = .unlessEditing
                
                field.translatesAutoresizingMaskIntoConstraints = false
                field.leftView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                field.leftView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
        }
    }
    
    func createLocation() {
        print("// --- ----- --- //")
        print("Creating Location ")
        /*
        ** Params: Every required parameter to insert
        **
        **
        */
        let requestArray = createRequestParameters()
        var request = requestArray[0] as! URLRequest
        var params = requestArray[1] as! [String: Any]
        
        // Insert to DB
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        let rowId = LocationData.data.addLocation(name: location.name!, address: location.address!, city: location.city!, postalCode: location.postalCode!, unit: location.unit, req: jsonData!)
        
        if rowId != nil {
            
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            print(String(data: jsonData!, encoding: .utf8)!)
            if ReachabilityTwo.isConnectedToNetwork() {
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print("error=\(error!)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(String(data: data, encoding: .utf8))")
                    } else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode  == 200 {
                        let json = try! JSON(data: data)
                        // Take id_location value and assign_location_production
                        if let locationId = json["location"]["id"].intValue as Int? {
                            self.location.id = locationId
                            self.location.rowId = rowId
                            if LocationData.data.updateLocationServerId(locationId: rowId!, remoteId: Int64(locationId)) {
                                print("Updated Location Id: \(locationId) for row: \(rowId!)")
                                self.location.status = .Uploaded
                            }
                            
                            if let productionId = self.getIdForProduction(list: self.location.allProductions, withString: self.location.productions.last?.title) {
                                params.updateValue(productionId, forKey: "production_id")
                                self.location.productions.last?.productionId = productionId
                                
                                if (LocationData.data.addProduction(locationId: locationId,
                                                                    prodId: (self.location.productions.last?.productionId)!,
                                                                    scriptName: (self.location.productions.first?.storyLocationName)!) != nil) {
                                    self.assignProduction(for: self.location.productions.first!, withLocationId: locationId)
                                    LocationData.data.selectAllFromProductions()
                                }
                            }
                        } else {
                            print("No locationID ..... \(error!)")
                            return
                        }
                        
                        print(json)
                    }
                    
                    
                }; task.resume()
            } else {
                Queue.taskQueue.main.tasks += {
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            print("error=\(error!)")
                            return
                        }
                        
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(httpStatus)")
                        } else if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode  == 200 {
                            let json = try! JSON(data: data)
                            // Take id_location value and assign_location_production
                            if let locationId = json["location"]["id"].intValue as Int?{
                                self.location.id = locationId
                                if LocationData.data.updateLocationServerId(locationId: rowId!, remoteId: Int64(locationId)) {
                                    print("Updated Location Id: \(locationId) for row: \(rowId!)")
                                    self.location.status = .Uploaded
                                }
                                
                                print("locaion id    \(self.location.id!)")
                                print(self.location.assets)
                                
                                if self.location.productions.isEmpty {
                                    if self.location.id != nil && !self.location.assets.isEmpty {
                                        if LocationData.data.addPhoto(path: self.location.photoPath!, locationId: self.location.id!) != nil {
                                            let AWS = S3(accessKey: "",
                                                         secretKey: "",
                                                         identityPool: "",
                                                         bucketName: "locationaction-min",
                                                         assets: self.location.assets,
                                                         locId: self.location.id!,
                                                         token: self.token!)
                                            AWS.configureS3()
                                            self.location.status = .Uploaded
                                        }
                                        let itworks = LocationData.data.updateLocationPhotoNumber(locationId: Int64(self.location.id!), numberOfPhotos: self.location.assets.count)
                                        print("update location photo numbers = \(itworks) ... number of assets = \(self.location.assets.count)")
                                    } else {
                                        print("\n self.location.id != nil && !self.location.assets.isEmpty  -----> FALSE \n locationId: \(self.location.id ?? 0) asssets: \(self.location.assets)")
                                    }
                                } else {
                                    if let productionId = self.getIdForProduction(list: self.location.allProductions, withString: self.location.productions.last?.title) {
                                        params.updateValue(productionId, forKey: "production_id")
                                        self.location.productions.first?.productionId = productionId
                                        // crear imagen sin url pero con locacion en DB
                                        // al crear url leer asignar la url segun el location.id
                                        
                                        if (LocationData.data.addProduction(locationId: locationId,
                                                                            prodId: (self.location.productions.last?.productionId)!,
                                                                            scriptName: (self.location.productions.first?.storyLocationName)!) != nil) {
                                            self.assignProduction(for: self.location.productions.first!, withLocationId: locationId)
                                            LocationData.data.selectAllFromProductions()
                                        }
                                        if self.location.id != nil && !self.location.assets.isEmpty {
                                            if LocationData.data.addPhoto(path: self.location.photoPath!, locationId: self.location.id!) != nil {
                                                let AWS = S3(accessKey: "",
                                                             secretKey: "",
                                                             identityPool: "",
                                                             bucketName: "locationaction-min",
                                                             assets: self.location.assets,
                                                             locId: self.location.id!,
                                                             token: self.token!)
                                                AWS.configureS3()
                                                self.location.status = .Uploaded
                                            }
                                            let itworks = LocationData.data.updateLocationPhotoNumber(locationId: Int64(self.location.id!), numberOfPhotos: self.location.assets.count)
                                            print("update location photo numbers = \(itworks) ... number of assets = \(self.location.assets.count)")
                                        } else {
                                            print("\n self.location.id != nil && !self.location.assets.isEmpty  -----> FALSE \n locationId: \(self.location.id ?? 0) asssets: \(self.location.assets)")
                                        }
                                    }
                                }
                                
                                
                                
                            } else {
                                print("No locationID ..... \(error!)")
                                return
                            }
                            
                            print(json)
                        }
                        
                        
                    }; task.resume()
                }
            }
            
        }
    
    }
    
    func assignProduction(for production: ProductionModel, withLocationId locationId: Int){
        var request = URLRequest(url: URL(string: Urls.create)!)
        request.httpMethod = "POST"
        let params = ["session_id": token!,
                      "productions": ["0": ["id_location": locationId, "id_production": production.productionId, "script_name": production.storyLocationName]]
            ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        print("     -- ----      ---- --")
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
    
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        

        adjustTextField(textField, scrollView: scrollView)

//
//        listPickerView.reloadAllComponents()
//
//        drawValidate(activeTextField)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn...")
        drawValidate(textField)
        return true
    }
    
    func drawValidate(_ textField: UITextField){
        validator.validateField(textField){ error in
            print("Errro")
            print(error)
            if error == nil {
                let field = textField
                field.layer.borderColor = UIColor.lightGray.cgColor
                field.layer.borderWidth = 1.0
                field.leftView = nil

                if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                    nextField.becomeFirstResponder()
                    adjustTextField(nextField, scrollView: scrollView)
                } else {
                    textField.resignFirstResponder()
                }
            } else {
                let field = textField
                field.layer.borderColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1).cgColor
                field.layer.borderWidth = 1.0
                field.leftView = UIImageView(image: #imageLiteral(resourceName: "Alert Icon"))
                field.leftView?.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1)
                field.leftView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                field.leftView?.contentMode = .scaleAspectFit
                field.leftViewMode = .unlessEditing
                
                field.translatesAutoresizingMaskIntoConstraints = false
                field.leftView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                field.leftView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        } else if textField.isEqual(otherPhoneTextField) {
            print("otherPhoneTextField")
            if (textField.text?.count)! == 0 {
                print("equal 0")
                validator.unregisterField(otherPhoneTextField!)
            } else {
                validator.registerField(otherPhoneTextField!, rules: [PhoneNumberRule()])
            }
            
            //return
        } else if textField.isEqual(emailTextField) {
            print("emailTextField")
            if (textField.text?.count)! == 0 {
                print("equal 0")
                validator.unregisterField(emailTextField!)
            } else {
                validator.registerField(emailTextField!, rules: [EmailRule(), MaxLengthRule(length: 40)] )
            }
    
    //return
}
        
        validator.validateField(textField){ error in
            
            if error == nil {
                let field = textField
                field.layer.borderColor = UIColor.lightGray.cgColor
                field.layer.borderWidth = 1.0
                field.leftView = nil
            } else {
                let field = textField
                field.layer.borderColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1).cgColor
                field.layer.borderWidth = 1.0
                field.leftView = UIImageView(image: #imageLiteral(resourceName: "Alert Icon"))
                field.leftView?.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1)
                field.leftView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                field.leftView?.contentMode = .scaleAspectFit
                field.leftViewMode = .unlessEditing
                
                field.translatesAutoresizingMaskIntoConstraints = false
                field.leftView?.widthAnchor.constraint(equalToConstant: 30).isActive = true
                field.leftView?.heightAnchor.constraint(equalToConstant: 30).isActive = true
            }
        }

        
        guard
            let center = centerTextField.text, !center.isEmpty,
            let name = locationNameTextField.text, !name.isEmpty,
            let address = locationAddressTextField.text, !address.isEmpty,
            let country = countryTextField.text, !country.isEmpty,
            let state = stateTextField.text, !state.isEmpty,
            let city = cityTextField.text, !city.isEmpty,
            let firstName = firstNameTextField.text, !firstName.isEmpty,
            let lastName = lastNameTextField.text, !lastName.isEmpty,
            let mainTel = primaryPhoneTextField.text, !mainTel.isEmpty
            else {
                if selectedCategory.count < 0 {
                    addMoreInfoButton.isEnabled = false
                    createLocationButton.isEnabled = false
                }
                
                return
        }
        
        guard let countryy = countryTextField.text, !countryy.isEmpty else {
            stateTextField.isEnabled = false
            cityTextField.isEnabled = false
            postalCodeTextField.isEnabled = false
            return
        }
        if selectedCategory.count > 0 {
            addMoreInfoButton.isEnabled = true
            createLocationButton.isEnabled = true
        }
        
    }
    
    
    
    
    // MARK: PickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView{
        case centerPickerView:
            return listDataCenter.count
        case countryPickerView:
            return listCountry.count
        case statePicerkView:
            return  listState.count
        default:
            return currentData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch pickerView{
        case centerPickerView:
            return listDataCenter[row]
        case countryPickerView:
            return listCountry[row]
        case statePicerkView:
            return listState[row]
        default:
            return currentData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // TODO: Make default value for picker view
        if pickerView == centerPickerView{
            centerTextField.text = listDataCenter[row]
        }
        
        if pickerView == countryPickerView{
            countryTextField.text = listCountry[row]
            let countryId = getIdByName(list: location.allCountries, withString: countryTextField.text)!;
            getStatesByCountryId(countryId: countryId)
            listState = location.stateList.sorted()
            
            stateTextField.isEnabled = true
            
            if countryTextField.text != nil {
                if countryTextField.text == "" {
                    stateTextField.isEnabled = false
                }else{
                    stateTextField.isEnabled = true
                }
            }
        }
        
        if pickerView == statePicerkView{
            stateTextField.text = listState[row]
        }
        
        
    }
    
    // PickrView View
    
    func createPickerToolBar() {
        
        let pickerToolBar = UIToolbar()
        pickerToolBar.barStyle = .blackTranslucent
        pickerToolBar.sizeToFit()
        
        let pre = Locale.preferredLanguages[0]
        var doneText = "Done"
        var cancelText = "Cancel"
        
        if !pre.contains("en") {
            doneText = "Continuar"
            cancelText = "Cancelar"
        }
        
        let doneButton = UIBarButtonItem(title: doneText, style: .plain, target: self, action: #selector(chooseItemFromPicker))
        let toolBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: cancelText, style: .plain, target: self, action: #selector(cancelItemFromPicker))
        
        doneButton.tintColor = UIColor.white
        cancelButton.tintColor = UIColor.white
        
        pickerToolBar.setItems([cancelButton, toolBarSpace, doneButton], animated: true)
        
        centerTextField.inputAccessoryView = pickerToolBar
        stateTextField.inputAccessoryView = pickerToolBar
        countryTextField.inputAccessoryView = pickerToolBar
    }
    
    @objc func chooseItemFromPicker() {
        self.view.endEditing(true)
        checkIfCanBeActive()
        //activeTextField.resignFirstResponder()
    }
    
    @objc func cancelItemFromPicker() {
        checkIfCanBeActive()
        if activeTextField.text == nil || (activeTextField.text?.isEmpty)! {
           activeTextField.text = ""
        }
        activeTextField.resignFirstResponder()
    }
    
    func checkIfCanBeActive() {
        if stateTextField.text != nil {
            countyTextField.isEnabled = true
            cityTextField.isEnabled = true
            if stateTextField.text == "" {
                countyTextField.isEnabled = false
                cityTextField.isEnabled = false
            }
        } else if countryTextField.text != nil {
            if countryTextField.text == "" {
                stateTextField.isEnabled = false
            }
            stateTextField.isEnabled = true
        }
    }
    
    @objc func goback(_ sender: UIBarButtonItem?) {
        if locationNameTextField.text != "" || locationAddressTextField.text != "" {
            let alert = UIAlertController(title: NSLocalizedString("ARE YOU SURE?", comment: "") , message: NSLocalizedString("This location's information will be erased", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                
                _ = self.navigationController?.popViewController(animated: true)
                
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: Image Picker
    
    func setupImagePicker() {
        let imagePicker = BSImagePickerViewController()
        
        imagePicker.takePhotos = true
        imagePicker.takePhotoIcon = #imageLiteral(resourceName: "Photo Camera Icon").withRenderingMode(.alwaysTemplate)
        imagePicker.maxNumberOfSelections = 60

        imagePicker.navigationBar.barTintColor = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.albumButton.tintColor = UIColor.white
        imagePicker.cancelButton.tintColor = UIColor.white
        imagePicker.doneButton.image = UIImage(named: "Front Camera Icon")
        imagePicker.doneButton.tintColor = UIColor.white
        imagePicker.selectionCharacter = "✓"
        imagePicker.selectionFillColor = UIColor.white
        imagePicker.selectionStrokeColor = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.selectionShadowColor = UIColor.gray
        imagePicker.selectionTextAttributes[NSAttributedStringKey.foregroundColor] = uicolorFromHex(rgbValue: 0xed1e3e)
        imagePicker.cellsPerRow = {(verticalSize: UIUserInterfaceSizeClass, horizontalSize: UIUserInterfaceSizeClass) -> Int in
            switch (verticalSize, horizontalSize) {
            case (.compact, .regular): // iPhone5-6 portrait
                return 4
            case (.compact, .compact): // iPhone5-6 landscape
                return 6
            case (.regular, .regular): // iPad portrait/landscape
                return 6
            default:
                return 4
            }
        }
        var activityView: UIActivityIndicatorView?
        var counterAssets = 0
        bs_presentImagePickerController(imagePicker, animated: true,
                                        select: {
                                            (asset: PHAsset) -> Void in
                                            print("Selected: \(asset)")
                                            counterAssets += 1
                                            print(counterAssets)
                                            if counterAssets >= 60 {
                                                let alert = UIAlertController(title: NSLocalizedString("PHOTO LIMIT", comment: ""), message: NSLocalizedString("You've reached the maximum limit of photos: 60", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
                                                
                                                DispatchQueue.main.async {
                                                    imagePicker.present(alert, animated: true, completion: nil)
                                                }
                                                
                                                
                                            }
        }, deselect: { (asset: PHAsset) -> Void in
            print("Deselected: \(asset)")
            counterAssets -= 1
        }, cancel: { (assets: [PHAsset]) -> Void in
            print("Cancel: \(assets)")
            DispatchQueue.main.async {
                //self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                self.navigationController?.popViewController(animated: true)
            }
        }, finish: { (assets: [PHAsset]) -> Void in
            print("Finish: \(assets)")
            // If location was created get location id and Save row to DB
            // Then upload to S3 and Post to server
            // If no location update the row
            if counterAssets > 0 {
                self.getAssetUrl(mPhasset: assets.first!, completionHandler: {
                    (responseURL: URL?) in
                    
                    print("responseURL", responseURL ?? "NO URL")
                    
                    let url = responseURL!
                    
                    if self.location.id != nil {
                        if LocationData.data.addPhoto(path: url.path, locationId: self.location.id!) != nil {
                            let AWS = S3(accessKey: "",
                                         secretKey: "",
                                         identityPool: "",
                                         bucketName: "locationaction-min",
                                         assets: assets,
                                         locId: self.location.id!,
                                         token: self.token!)
                            AWS.configureS3()
                            self.location.status = .Uploaded
                        }
                        
                        let itworks = LocationData.data.updateLocationPhotoNumber(locationId: Int64(self.location.id!), numberOfPhotos: assets.count)
                        print("update location photo numbers = \(itworks) ... number of assets = \(assets.count)")
                    }
                    
                    DispatchQueue.main.async {
                        
                        var titleMessage = ""
                        var message = ""
                        if ReachabilityTwo.isConnectedToNetwork() {
                            titleMessage = NSLocalizedString("Uploaded Location", comment: "")
                            message = NSLocalizedString("The location was successfully uploaded", comment: "")
                        } else {
                            titleMessage = NSLocalizedString("Location Added", comment: "")
                            message = NSLocalizedString("The location will be uploaded when you are online", comment: "")
                        }
                        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.navigationController?.popViewController(animated: true)
                        self.present(alert, animated: true, completion: nil)
                        
                        //self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                        
                    }
                    
                    activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
                    activityView?.color = #colorLiteral(red: 0.9538540244, green: 0.2200518847, blue: 0.3077117205, alpha: 1)
                    activityView?.center = self.view.center
                    activityView?.startAnimating()
                    self.view.addSubview(activityView!)
                    
                    
                    self.location.assets = assets
                    self.location.photoPath = url.path
                    print(url)
                })
            } else {
                DispatchQueue.main.async {
                    //self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        }, completion: {
            activityView?.hidesWhenStopped = true
            activityView?.stopAnimating()
        })
    }
    
    func photolibrarySelected() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let authStatus = PHPhotoLibrary.authorizationStatus()
            switch authStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.setupImagePicker()
                }
            case .denied:
                alertPromptToAllowPhotoLibraryAccessViaSettings()
            case .notDetermined:
                permissionPrimePhotoLibraryAccess()
            default:
                permissionPrimePhotoLibraryAccess()
            }
            
        } else {
            let alertController = UIAlertController(title: "Error", message: "Device has no photo library", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                DispatchQueue.main.async {
                    //self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                    self.navigationController?.popViewController(animated: true)
                }
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func cameraSelected() {
        // First we check if the device has a camera (otherwise will crash in Simulator - also, some iPod touch models do not have a camera).
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch authStatus {
            case .authorized:
                DispatchQueue.main.async {
                    self.setupImagePicker()
                }
            case .denied:
                alertPromptToAllowCameraAccessViaSettings()
            case .notDetermined:
                permissionPrimeCameraAccess()
            default:
                permissionPrimeCameraAccess()
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                }
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func alertPromptToAllowCameraAccessViaSettings() {
        let alert = UIAlertController(title: NSLocalizedString("LOCATIONS Would Like To Access the Camera", comment: "") , message: NSLocalizedString("Please grant permission to use the Camera so that you can take photos.", comment: ""), preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .cancel) { alert in
            if let appSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowPhotoLibraryAccessViaSettings() {
        let alert = UIAlertController(title: NSLocalizedString("LOCATIONS Would Like To Access the Photo Libary", comment: ""), message: NSLocalizedString("Please grant permission to use the Library so that you can upload Locations with photos", comment: ""), preferredStyle: .alert )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open Settings", comment: ""), style: .cancel) { alert in
            if let appSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    
    func permissionPrimeCameraAccess() {
        let alert = UIAlertController( title: "LOCATIONS Would Like To Access the Camera", message: "Locations would like to access your Camera so that you can take pictures.", preferredStyle: .alert )
        let allowAction = UIAlertAction(title: "Allow", style: .default, handler: { (alert) -> Void in
            //Analytics.track(event: .permissionsPrimeCameraAccepted)
//            if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
//                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] granted in
//                    DispatchQueue.main.async {
//                        //self?.cameraTabSelected() // try again
//                    }
//                })
//            }
        })
        alert.addAction(allowAction)
        let declineAction = UIAlertAction(title: "Not Now", style: .cancel) { (alert) in
            
        }
        alert.addAction(declineAction)
        present(alert, animated: true, completion: nil)
    }
    
    func permissionPrimePhotoLibraryAccess() {
        let alert = UIAlertController( title: NSLocalizedString("LOCATIONS Would Like To Access the Photo Libary", comment: ""), message: NSLocalizedString("LOCATIONS would like to access your Library so that you can upload locations with photos.", comment: ""), preferredStyle: .alert )
        let allowAction = UIAlertAction(title: NSLocalizedString("Allow", comment: ""), style: .default, handler: { (alert) -> Void in
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    DispatchQueue.main.async {
                        self.setupImagePicker()
                    }
                case .denied, .restricted:
                    print("help")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                    }
                case .notDetermined:
                    print("note determined")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                    }
                default: break;
                }
                
                
            }
            
        })
        alert.addAction(allowAction)

        let declineAction = UIAlertAction(title: NSLocalizedString("Not Now", comment: ""), style: .cancel) { (aler) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
            }
        }
        alert.addAction(declineAction)
        present(alert, animated: false, completion: nil)
    }
}

// MARK: - Table View

extension CreationViewController: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(selectionTableView) {
            return 1
        } else if tableView.isEqual(subcategoryTableView) {
            return 1
        } else if tableView.isEqual(attributesTableView) {
            return selectedAttributes.count
        } else if tableView.isEqual(contactsTableView) {
            return location.contacts.count
        } else if tableView.isEqual(productionTableView) {
            return location.productions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SelectionCell.identifier, for: indexPath) as? SelectionCell {
            cell.delegate = self
            cell.selectionStyle = .none
            if tableView.isEqual(selectionTableView) {
                cell.titleLabel.text = NSLocalizedString(SelectionCell.selectionTitles[indexPath.row], comment: "")
                cell.layer.borderWidth = 1.0
                if(selectedCategory.count >  0){
                    cell.layer.borderColor = UIColor.lightGray.cgColor
                }else{
                    cell.layer.borderColor = #colorLiteral(red: 0.9920389056, green: 0.2018878758, blue: 0.3119233251, alpha: 1)
                }
                cell.titleLabel?.textAlignment = .center
                cell.tintColor = UIColor.darkGray
            } else if tableView.isEqual(subcategoryTableView) {
                cell.titleLabel.text = NSLocalizedString(SelectionCell.selectionTitles[1], comment: "")
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.titleLabel?.textAlignment = .center
                cell.tintColor = UIColor.darkGray
            } else if tableView.isEqual(attributesTableView) {
                cell.accessoryType = .none
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = selectedAttributes[indexPath.row]
            } else if tableView.isEqual(contactsTableView){
                cell.accessoryType = .none
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = "\(location.contacts[indexPath.row].firstName)  \(location.contacts[indexPath.row].lastName)"
            } else if tableView.isEqual(productionTableView){
                cell.accessoryType = .none
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = "TITLE:  \(location.productions[indexPath.row].title)"
            }
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEqual(subcategoryTableView) {
            self.performSegue(withIdentifier: "Subcategory", sender: self)
        } else  if tableView.isEqual(selectionTableView) {
            tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
            self.performSegue(withIdentifier: "Category", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.isEqual(selectionTableView) {
            return false
        }
        
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            if tableView.isEqual(self.contactsTableView) {
                self.location.contacts.remove(at: indexPath.row)
                self.contactsTableView.reloadData()
                self.adjustHeightOfTableView(self.contactsTableView)
            } else if tableView.isEqual(self.productionTableView) {
                self.location.productions.remove(at: indexPath.row)
                self.productionTableView.reloadData()
                self.adjustHeightOfTableView(self.productionTableView)
            } else if tableView.isEqual(self.attributesTableView) {
                self.selectedAttributes.remove(at: indexPath.row)
                self.attributesTableView.reloadData()
                self.adjustHeightOfTableView(self.attributesTableView)
            }
        }

        deleteAction.backgroundColor = UIColor(red: 259/250, green: 109/250, blue: 118/250, alpha: 1.0)
        deleteAction.image = #imageLiteral(resourceName: "Trash Icon").imageResize(sizeChange: CGSize(width: 18, height: 24))
        
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive(automaticallyDelete: false)
        options.transitionStyle = .border
        return options
    }
    
    
    
}


// MARK: - Navigation

extension CreationViewController: SelectionItemDelegate {
    
    // MARK: Unwind
    @IBAction func unwindToView(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? SelectionItemViewController {
            switch sourceViewController.selector {
                
            case .category:
                print("me oyen... me escuchan")
                selectedCategory = [sourceViewController.checkedItems[0]]
                
                let index: IndexPath = IndexPath(row: 0, section: 0)
                SelectionCell.selectionTitles[index.row] = selectedCategory.last!
                location.subcategoryList = self.getSubcategoriesByCategory(category: selectedCategory[0])
                if !location.subcategoryList.isEmpty {
                    subCategoryLabelHeightConstraint.constant = 15
                    subcategoryTableHeightConstraint.constant = 30
                } else {
                    subCategoryLabelHeightConstraint.constant = 0
                    subcategoryTableHeightConstraint.constant = 0
                    SelectionCell.selectionTitles[1] = "SELECT"
                }
                editingChanged(firstNameTextField)
                SelectionCell.selectionTitles[1] = "SELECT"
                subcategoryTableView.reloadData()
                selectionTableView.reloadData()
                adjustHeightOfTableView(selectionTableView)
                
            case .subcategory:
                selectedSubcategory = sourceViewController.checkedItems
                let index: IndexPath = IndexPath(row: 1, section: 0)
                SelectionCell.selectionTitles[index.row] = selectedSubcategory.last!
                subcategoryTableView.reloadData()
                
            case .attribute:
                selectedAttributes = sourceViewController.checkedItems
                attributesTableView.reloadData()
                adjustHeightOfTableView(attributesTableView)
            default:
                print("")
            }
        } else if let sourceViewController = sender.source as? ContactViewController {
            if sourceViewController.contactIndex != nil {
                location.contacts[sourceViewController.contactIndex!] = sourceViewController.contact
            } else {
                self.location.contacts.append(sourceViewController.contact)
            }
            print("adjunsting contacts table view from contactview controller")
            contactsTableView.rowHeight = UITableViewAutomaticDimension
            contactsTableView.reloadData()
            self.adjustHeightOfTableView(contactsTableView)
        } else if let sourceViewController = sender.source as? ProductionLocationViewController {
            self.location.productions.append(sourceViewController.production)
            print("adjunsting production table view from ProductionLocationViewController controller")
            productionTableView.rowHeight = UITableViewAutomaticDimension
            productionTableView.reloadData()
            self.adjustHeightOfTableView(productionTableView)
        }
    }
    
    
    // MARK: Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "Contact" {
            _ = segue.destination as! ContactViewController
        } else if segue.identifier == "Contact Detail" {
            let contactVC = segue.destination as! ContactViewController
            if location.contacts.count > 0 {
                contactVC.contactIndex = location.contactIndex
                contactVC.contact = location.contacts[location.contactIndex!]
            }
        } else if segue.identifier == "Camera" {
            let cameraVC = segue.destination as! CameraViewController
            cameraVC.location = self.location
            cameraVC.token = self.token
        } else if segue.identifier == "unwindToMainMenu" {
            let homeVC = segue.destination as! MainMenuViewController
            homeVC.token = UserDefaults.standard.string(forKey: "app_token")
            homeVC.user = self.user
            var titleMessage = ""
            var message = ""
            if ReachabilityTwo.isConnectedToNetwork() {
                titleMessage = NSLocalizedString("Uploaded Location", comment: "")
                message = NSLocalizedString("The location was successfully uploaded", comment: "")
            } else {
                titleMessage = NSLocalizedString("Location Added", comment: "")
                message = NSLocalizedString("The location will be uploaded when you are online", comment: "")
            }
            homeVC.alert = UIAlertController(title: titleMessage, message: message, preferredStyle: UIAlertControllerStyle.alert)
            homeVC.alert?.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        } else if segue.identifier == "unwindToMainMenuWithoutData" {
            let homeVC = segue.destination as! MainMenuViewController
            homeVC.alert = nil
            homeVC.token = UserDefaults.standard.string(forKey: "app_token")
            homeVC.user = self.user
        } else if segue.identifier == "More Info" {
            let creationVC = segue.destination as! ExtraInfoCreationViewController
                creationVC.location = self.location
            } else {
            let selectionItemsVC = segue.destination as! SelectionItemViewController
            
            switch segue.identifier! {
            case "Category":
                
                selectionItemsVC.selectionItems = self.location.categoryList.sorted(by: {$0.lowercased() < $1.lowercased() })
                print(selectionItemsVC.selectionItems)
                selectionItemsVC.selectionType = .single
                if !selectedCategory.isEmpty {
                    selectionItemsVC.checkedItems.append(contentsOf: selectedCategory)
                }
                selectionItemsVC.selector = .category
                selectionItemsVC.delegate = self
            case "Subcategory":
                selectionItemsVC.selectionItems = self.location.subcategoryList.sorted(by: {$0.lowercased() < $1.lowercased() })
                selectionItemsVC.selectionType = .single
                if !selectedSubcategory.isEmpty {
                    selectionItemsVC.checkedItems.append(contentsOf: selectedSubcategory)
                }
                selectionItemsVC.selector = .subcategory
                selectionItemsVC.delegate = self
            case "Attribute":
                selectionItemsVC.selectionItems = self.location.attributesList.sorted(by: {$0.lowercased() < $1.lowercased() })
                if !selectedAttributes.isEmpty {
                    selectionItemsVC.checkedItems.append(contentsOf: selectedAttributes)
                }
                selectionItemsVC.selectionType = .multiple
                selectionItemsVC.selector = .attribute
                selectionItemsVC.delegate = self
            case "Production":
                selectionItemsVC.selectionItems = self.location.productionList.sorted(by: {$0.lowercased() < $1.lowercased() })
                selectionItemsVC.selectionType = .single
                selectionItemsVC.selector = .production
                
            default:
                print(segue.identifier!)
            }
        }
        
    }
    
    // MARK: Delegate Selection
    func saveSelection(controller: SelectionItemViewController) {
        switch controller.selector {
        case .category:
            selectedCategory = controller.checkedItems
            let index: IndexPath = IndexPath(row: 0, section: 0)
            SelectionCell.selectionTitles[index.row] = selectedCategory.last!
            location.subcategoryList = self.getSubcategoriesByCategory(category: selectedCategory.last!)
            if !location.subcategoryList.isEmpty {
                subCategoryLabelHeightConstraint.constant = 15
                subcategoryTableHeightConstraint.constant = 30
            } else {
                subCategoryLabelHeightConstraint.constant = 0
                subcategoryTableHeightConstraint.constant = 0
                SelectionCell.selectionTitles[1] = "SELECT"
            }
            editingChanged(firstNameTextField)
            SelectionCell.selectionTitles[1] = "SELECT"
            selectedSubcategory = []
            subcategoryTableView.reloadData()
            selectionTableView.reloadData()
            adjustHeightOfTableView(selectionTableView)
            
        case .subcategory:
            selectedSubcategory = controller.checkedItems
            let index: IndexPath = IndexPath(row: 1, section: 0)
            SelectionCell.selectionTitles[index.row] = selectedSubcategory.last!
            subcategoryTableView.reloadData()
            
        case .attribute:
            selectedAttributes = controller.checkedItems
            attributesTableView.reloadData()
            adjustHeightOfTableView(attributesTableView)
        default:
            print("")
        }
    }
}

// MARK: - String Extension

extension CreationViewController {
    struct Identifier {
        static let Login = "unwindToLoginVC"
        static let Server = "server_url"
    }
    
    struct Urls {
        static let create =  UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.ServerURL)! + "/location_modules/assign_location_productions"
    }
}
