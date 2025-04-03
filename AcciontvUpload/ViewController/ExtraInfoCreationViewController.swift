//
//  ExtraInfoCreationViewController.swift
//  AcciontvUpload
//
//  Created by Diego Salazar on 9/7/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwiftValidator
import SwipeCellKit

class ExtraInfoCreationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var otherContactsTableView: UITableView!
    @IBOutlet weak var parkingTableView: UITableView!
    @IBOutlet weak var otherContactsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationDescriptionTextView: UITextView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var availableFromTextField: UITextField!
    @IBOutlet weak var availableToTextField: UITextField!
    @IBOutlet weak var locationTypeTextField: UITextField!
    @IBOutlet weak var locationTimeTextField: UITextField!
    @IBOutlet weak var rateTypeTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var rateFromTextField: UITextField!
    @IBOutlet weak var rateToTextField: UITextField!
    @IBOutlet weak var OtphTextField: UITextField!
    @IBOutlet weak var routeTextView: UITextView!
    @IBOutlet weak var parkingTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var personalVehiclesAvailabilitySwitch: UISwitch!
    @IBOutlet weak var addOtherContactButton: UIButton!
    @IBOutlet weak var addParkingButton: UIButton!
    @IBOutlet weak var saveMoreInfoButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var scheduleTableViewHeightConstraint: NSLayoutConstraint!
    
    var location: LocationModel = LocationModel()
    let validator = Validator()
    var selectedSchedule: String = ""
    var selectedAtrributes : [String] = []
    var selectedParking : [String] = []
    
    var currentData: [String] = []
    var activeTextField: UITextField!
    
    let listPickerView = UIPickerView()
    let fromDatePickerView = UIDatePicker()
    let toDatePickerView = UIDatePicker()
    var timeSelected = UITextField()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationIcons()
        
        
        //self.navigationItem.hidesBackButton = true
        //let newBackButton = CustomBackButton.createWithText(text: "", color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), target: self, action: #selector(back(sender:)))
        //self.navigationItem.leftBarButtonItems = newBackButton
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:self, action: #selector(back(sender:)))
        
        otherContactsTableView.delegate = self
        otherContactsTableView.dataSource = self
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        parkingTableView.delegate = self
        parkingTableView.dataSource = self
        
        availableFromTextField.delegate = self
        availableToTextField.delegate = self
        locationTypeTextField.delegate = self
        locationTimeTextField.delegate = self
        rateTypeTextField.delegate = self
        currencyTextField.delegate = self
        rateFromTextField.delegate = self
        rateToTextField.delegate = self
        OtphTextField.delegate = self
        
        availableFromTextField.layer.borderWidth = 1.0
        availableToTextField.layer.borderWidth = 1.0
        locationTypeTextField.layer.borderWidth = 1.0
        locationTimeTextField.layer.borderWidth = 1.0
        rateTypeTextField.layer.borderWidth = 1.0
        currencyTextField.layer.borderWidth = 1.0
        rateFromTextField.layer.borderWidth = 1.0
        rateToTextField.layer.borderWidth = 1.0
        OtphTextField.layer.borderWidth = 1.0
        addOtherContactButton.layer.borderWidth = 1.0
        addParkingButton.layer.borderWidth = 1.0
        saveMoreInfoButton.layer.borderWidth = 1.0
        scheduleButton.layer.borderWidth = 1.0
        
        availableFromTextField.layer.borderColor = UIColor.lightGray.cgColor
        availableToTextField.layer.borderColor = UIColor.lightGray.cgColor
        locationTypeTextField.layer.borderColor = UIColor.lightGray.cgColor
        locationTimeTextField.layer.borderColor = UIColor.lightGray.cgColor
        rateTypeTextField.layer.borderColor = UIColor.lightGray.cgColor
        currencyTextField.layer.borderColor = UIColor.lightGray.cgColor
        rateFromTextField.layer.borderColor = UIColor.lightGray.cgColor
        rateToTextField.layer.borderColor = UIColor.lightGray.cgColor
        OtphTextField.layer.borderColor = UIColor.lightGray.cgColor
        addOtherContactButton.layer.borderColor = UIColor.lightGray.cgColor
        addParkingButton.layer.borderColor = UIColor.lightGray.cgColor
        saveMoreInfoButton.layer.borderColor = UIColor.lightGray.cgColor
        scheduleButton.layer.borderColor = UIColor.lightGray.cgColor
        
        availableFromTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        availableFromTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        availableFromTextField.rightView?.contentMode = .scaleAspectFit
        availableFromTextField.rightViewMode = .unlessEditing
        
        availableToTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        availableToTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        availableToTextField.rightView?.contentMode = .scaleAspectFit
        availableToTextField.rightViewMode = .unlessEditing
        
        locationTypeTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        locationTypeTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        locationTypeTextField.rightView?.contentMode = .scaleAspectFit
        locationTypeTextField.rightViewMode = .unlessEditing
        
        locationTimeTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        locationTimeTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        locationTimeTextField.rightView?.contentMode = .scaleAspectFit
        locationTimeTextField.rightViewMode = .unlessEditing
        
        rateTypeTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        rateTypeTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        rateTypeTextField.rightView?.contentMode = .scaleAspectFit
        rateTypeTextField.rightViewMode = .unlessEditing
        
        currencyTextField.rightView = UIImageView(image: #imageLiteral(resourceName: "Arrow Down"))
        currencyTextField.rightView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        currencyTextField.rightView?.contentMode = .scaleAspectFit
        currencyTextField.rightViewMode = .unlessEditing
        
        otherContactsTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        scheduleTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        parkingTableView?.register(SelectionCell.nib, forCellReuseIdentifier: SelectionCell.identifier)
        
        scheduleTableView.rowHeight = 30
        
        listPickerView.delegate = self
        listPickerView.dataSource = self
        
        locationTypeTextField.inputView = listPickerView
        locationTimeTextField.inputView = listPickerView
        rateTypeTextField.inputView = listPickerView
        currencyTextField.inputView = listPickerView
        
        createPickerToolBar()
        
        validator.registerField(rateFromTextField, rules: [MaxLengthRule(length: 6)])
        validator.registerField(rateToTextField, rules: [MaxLengthRule(length: 6)])
        validator.registerField(OtphTextField, rules: [MaxLengthRule(length: 6)])
        
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.scheduleTableView.indexPathForSelectedRow {
            self.scheduleTableView.deselectRow(at: index, animated: true)
        } else if let index = self.otherContactsTableView.indexPathForSelectedRow {
            self.otherContactsTableView.deselectRow(at: index, animated: true)
        }  else if let index = self.parkingTableView.indexPathForSelectedRow {
            self.parkingTableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        self.adjustHeightOfTableView(otherContactsTableView)
        self.adjustHeightOfTableView(scheduleTableView)
        self.adjustHeightOfTableView(parkingTableView)
        
        listPickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    
    @IBAction func saveInfo(_ sender: UIButton) {
        validator.validate(self)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        // ...
        // Go back to the previous ViewController
        let alert = UIAlertController(title: "ALERT", message: "Are you sure you want to leave without saving", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
            
            _ = self.navigationController?.popViewController(animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    // MARK: Picker change
    
    @IBAction func pickUpDate(_ sender: UITextField) {
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .time
        sender.inputView = datePickerView
        timeSelected = sender
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.allEvents)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh: mm a"
        
        timeSelected.text = dateFormatter.string(from: sender.date)
    }
    
    func createFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh: mm a"
        
        return formatter
    }
    
    func fromDateChanged(_ sender: UIDatePicker) {
        let formatter = createFormatter()
        availableToTextField.text = formatter.string(from: fromDatePickerView.date)
    }
    
    func toDateChanged(_ sender: UIDatePicker) {
        let formatter = createFormatter()
        availableToTextField.text = formatter.string(from: toDatePickerView.date)
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = textField
        self.adjustTextField(activeTextField, scrollView: scrollView)
        
        switch textField {
        case availableFromTextField:
            pickUpDate(textField)
        case availableToTextField:
            pickUpDate(textField)
        case locationTypeTextField:
            currentData = location.typeList
        case locationTimeTextField:
            currentData = location.shootingList.sorted()
        case rateTypeTextField:
            currentData = location.rateTypeList.sorted()
        case currencyTextField:
            currentData = location.currencyList.sorted()
        default:
            print("")
        }
        
        listPickerView.reloadAllComponents()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
            self.adjustTextField(nextField, scrollView: scrollView)
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

}

// MARK: - Table View
extension ExtraInfoCreationViewController: UITableViewDataSource, UITableViewDelegate, SwipeTableViewCellDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(otherContactsTableView) {
            return self.location.otherContacts.count
        } else if tableView.isEqual(scheduleTableView) {
            if selectedSchedule == "" {
                return 0
            }
            return 1
        } else if tableView.isEqual(parkingTableView) {
            return selectedParking.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: SelectionCell.identifier, for: indexPath) as? SelectionCell {
            cell.delegate = self
            cell.accessoryType = .none
            cell.selectionStyle = .none
            if tableView.isEqual(otherContactsTableView) {
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = "\(location.otherContacts[indexPath.row].firstName)  \(location.otherContacts[indexPath.row].lastName)"
            } else if tableView.isEqual(scheduleTableView) {
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = selectedSchedule
//                cell.accessoryType = .disclosureIndicator
//                cell.titleLabel.text = "SELECT DAYS"
//                cell.layer.borderWidth = 1.0
//                cell.layer.borderColor = UIColor.lightGray.cgColor
//                cell.titleLabel?.textAlignment = .center
//                cell.tintColor = UIColor.darkGray
            } else if tableView.isEqual(parkingTableView) {
                cell.layoutIfNeeded()
                cell.addBorderRight(size: 1.0, color: UIColor.lightGray)
                cell.addBorderBottom(size: 1.0, color: UIColor.lightGray)
                cell.titleLabel.text = selectedParking[indexPath.row]
            }
            
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEqual(otherContactsTableView) {

        } else if tableView.isEqual(scheduleTableView) {
//            tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.white
//            self.performSegue(withIdentifier: "Schedule", sender: self)
        } else if tableView.isEqual(parkingTableView) {
            
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if tableView.isEqual(scheduleTableView) {
//            return false
//        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            if tableView.isEqual(otherContactsTableView) {
                location.otherContacts.remove(at: indexPath.row)
                otherContactsTableView.reloadData()
                adjustHeightOfTableView(otherContactsTableView)
            } else if tableView.isEqual(parkingTableView) {
                print("Removing! Parking table view Index:: \(indexPath.row)")
                selectedParking.remove(at: indexPath.row)
                parkingTableView.reloadData()
                adjustHeightOfTableView(parkingTableView)
            } else if tableView.isEqual(scheduleTableView) {
                selectedSchedule = ""
                scheduleTableView.reloadData()
                adjustHeightOfTableView(scheduleTableView)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let deleteAction = SwipeAction(style: .destructive, title: nil) { (action, indexPath) in
            if tableView.isEqual(self.otherContactsTableView) {
                self.location.otherContacts.remove(at: indexPath.row)
                self.otherContactsTableView.reloadData()
                self.adjustHeightOfTableView(self.otherContactsTableView)
            } else if tableView.isEqual(self.parkingTableView) {
                print("Removing! Parking table view Index:: \(indexPath.row)")
                self.selectedParking.remove(at: indexPath.row)
                self.parkingTableView.reloadData()
                self.adjustHeightOfTableView(self.parkingTableView)
            } else if tableView.isEqual(self.scheduleTableView) {
                self.selectedSchedule = ""
                self.scheduleTableView.reloadData()
                self.adjustHeightOfTableView(self.scheduleTableView)
            }

        }
        
        deleteAction.backgroundColor = #colorLiteral(red: 0.9843137255, green: 0.4274509804, blue: 0.462745098, alpha: 1)
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

extension ExtraInfoCreationViewController {
    @IBAction func unwindToView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ContactViewController {
            if sourceViewController.contactIndex != nil {
                location.otherContacts[sourceViewController.contactIndex!] = sourceViewController.contact
            } else {
                self.location.otherContacts.append(sourceViewController.contact)
            }
            otherContactsTableView.reloadData()
        } else if let sourceViewController = sender.source as? SelectionItemViewController {
            switch sourceViewController.selector {
            case .parking:
                selectedParking = sourceViewController.checkedItems
                parkingTableView.reloadData()
                adjustHeightOfTableView(parkingTableView)
            case .schedule:
                selectedSchedule = sourceViewController.checkedItems.first!
                let days = sourceViewController.checkedItems
                print(days)
                scheduleTableView.reloadData()
                adjustHeightOfTableView(scheduleTableView)
            default:
                print("")
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Contact" {
            _ = segue.destination as! ContactViewController
        } else if segue.identifier == "unwindToViewSegueId"{
            let creationVC = segue.destination as! CreationViewController
            creationVC.location = self.location
        } else {
            let selectionItemVC = segue.destination as! SelectionItemViewController
            
            switch segue.identifier! {
            case "Schedule":
                var scheduleOptions = self.location.optionsSchedule
                scheduleOptions.append(contentsOf: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
                selectionItemVC.selectionItems = scheduleOptions
                selectionItemVC.selector = .schedule
                selectionItemVC.selectionType = .multiple
            case "Parking":
                selectionItemVC.selectionItems = self.location.parkingList
                selectionItemVC.selectionType = .multiple
                selectionItemVC.selector = .parking
            default:
                print("")
            }
        }
    }
}

// MARK: - PickerViewDelegate
extension ExtraInfoCreationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currentData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeTextField.text = NSLocalizedString(currentData[row], comment: "")
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
        
        availableFromTextField.inputAccessoryView = pickerToolBar
        availableToTextField.inputAccessoryView = pickerToolBar
        locationTypeTextField.inputAccessoryView = pickerToolBar
        locationTimeTextField.inputAccessoryView = pickerToolBar
        rateTypeTextField.inputAccessoryView = pickerToolBar
        currencyTextField.inputAccessoryView = pickerToolBar
    }
    
    @objc func chooseItemFromPicker() {
        activeTextField.resignFirstResponder()
    }
    
    @objc func cancelItemFromPicker() {
        activeTextField.text = ""
        activeTextField.resignFirstResponder()
    }
}

extension ExtraInfoCreationViewController: ValidationDelegate {
    func validationSuccessful() {
        location.descriptionLoc = locationDescriptionTextView.text
        location.schedule = selectedSchedule
        location.availableFrom = availableFromTextField.text
        location.availableTo = availableToTextField.text
        location.type = locationTypeTextField.text
        location.time = locationTimeTextField.text
        location.ratetype = rateTypeTextField.text
        location.currency = currencyTextField.text
        location.rateFrom = Int(rateFromTextField.text!)
        location.rateTo = Int(rateToTextField.text!)
        location.oTperHour = Int(OtphTextField.text!)
        location.route = routeTextView.text
        location.personalVehiclesAvailability = personalVehiclesAvailabilitySwitch.isOn
        
        self.performSegue(withIdentifier: "unwindToViewSegueId", sender: self)
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
            }
            error.errorLabel?.text = error.errorMessage
            error.errorLabel?.isHidden = false
            let alert = UIAlertController(title: "Error", message: error.errorMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ExtraInfoCreationViewController {
    func adjustHeightOfTableView(_ tableView: UITableView) {
        let height: CGFloat = tableView.contentSize.height;
        
        UIView.animate(withDuration: 0.5, animations: {
            if tableView.isEqual(self.otherContactsTableView) {
                self.otherContactsTableViewHeightConstraint.constant = height
            } else if tableView.isEqual(self.parkingTableView) {
                self.parkingTableViewHeightConstraint.constant = height
            } else if tableView.isEqual(self.scheduleTableView) {
                self.scheduleTableViewHeightConstraint.constant = height
            }
            
            self.view.setNeedsUpdateConstraints()
        })
    }
    
    override func adjustTextField(_ textField: UITextField, scrollView: UIScrollView) {
        let pointInTable:CGPoint = textField.superview!.convert(textField.frame.origin, to: scrollView)
        print(pointInTable)
        var contentOffset:CGPoint = scrollView.contentOffset
        contentOffset.y  = CGFloat(pointInTable.y) - 100
        print(contentOffset)
        if let accessoryView = textField.inputAccessoryView {
            print("accessotry view frame size heigt")
            print(accessoryView.frame.size.height)
            contentOffset.y -= accessoryView.frame.size.height
        }
        scrollView.contentOffset = contentOffset
    }
}
