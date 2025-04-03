//
//  ContactViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 5/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwiftValidator

class ContactViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var primaryPhoneTextField: UITextField!
    @IBOutlet weak var otherPhoneTextField: UITextField?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var contactView: UIView!
    @IBOutlet weak var saveContactButton: UIButton!
    
    var contact: ContactModel = ContactModel()
    let validator = Validator()
    var contactIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        primaryPhoneTextField.delegate = self
        otherPhoneTextField?.delegate = self
        emailTextField.delegate = self
        
        firstNameTextField.layer.borderWidth = 1.0
        lastNameTextField.layer.borderWidth = 1.0
        primaryPhoneTextField.layer.borderWidth = 1.0
        otherPhoneTextField?.layer.borderWidth = 1.0
        emailTextField.layer.borderWidth = 1.0
        saveContactButton.layer.borderWidth = 1.0
        
        saveContactButton.layer.borderColor = UIColor.lightGray.cgColor
        firstNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        lastNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        primaryPhoneTextField.layer.borderColor = UIColor.lightGray.cgColor
        otherPhoneTextField?.layer.borderColor = UIColor.lightGray.cgColor
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        firstNameTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        primaryPhoneTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        otherPhoneTextField?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        loadFields()
        
        validator.registerField(firstNameTextField, rules: [RequiredRule()])
        validator.registerField(lastNameTextField, rules: [RequiredRule()])
        validator.registerField(primaryPhoneTextField, rules: [RequiredRule(), PhoneNumberRule()])
        //validator.registerField(otherPhoneTextField!, rules: [PhoneNumberRule()])
        validator.registerField(emailTextField, rules: [EmailRule()])
        
        saveContactButton.isEnabled = false
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addContact(_ sender: Any) {
        validator.validate(self)
    }
    
    func loadFields() {
        firstNameTextField.text = contact.firstName
        lastNameTextField.text = contact.lastName
        primaryPhoneTextField.text = contact.primaryPhone
        otherPhoneTextField?.text = contact.otherPhone
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
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
            }
        }
        
        
        guard
            let firstn = firstNameTextField.text, !firstn.isEmpty,
            let lastn = lastNameTextField.text, !lastn.isEmpty,
            let primaryp = primaryPhoneTextField.text, !primaryp.isEmpty
            else {
                saveContactButton.isEnabled = false
                return
        }
        
        saveContactButton.isEnabled = true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            adjustTextField(textField)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        validator.validateField(textField){ error in
            if error == nil {
                let field = textField
                field.layer.borderColor = UIColor.lightGray.cgColor
                field.layer.borderWidth = 1.0
                field.leftView = nil
                
                if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                    nextField.becomeFirstResponder()
                    if nextField.isEqual(emailTextField) {
                        adjustTextField(textField)
                    }
                } else {
                    textField.resignFirstResponder()
                    if textField.isEqual(emailTextField) {
                        self.view.frame.origin.y = 0
                    }
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
            }
        }
        
        return false
    }
    
    func adjustTextField(_ textField: UITextField) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
    }

}

extension ContactViewController: ValidationDelegate {
    func validationSuccessful() {
        contact.firstName = firstNameTextField.text!
        contact.lastName = lastNameTextField.text!
        contact.primaryPhone = primaryPhoneTextField.text!
        contact.otherPhone = (otherPhoneTextField?.text)!
        contact.email = emailTextField.text!
        
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
