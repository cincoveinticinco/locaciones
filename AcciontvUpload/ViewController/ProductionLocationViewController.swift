//
//  ProductionLocationViewController.swift
//  AcciontvUpload
//
//  Created by Diego Salazar on 9/7/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwiftValidator

class ProductionLocationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var productionTitleLabel: UILabel!
    @IBOutlet weak var storyLocationNameTextField: UITextField!
    
    var production: ProductionModel = ProductionModel()
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationIcons()
        
        storyLocationNameTextField.delegate = self
        
        
        productionTitleLabel.text = production.title
        storyLocationNameTextField.layer.borderWidth = 1.0
        storyLocationNameTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        self.hideKeyboardWhenTappedAround()
        
        validator.registerField(storyLocationNameTextField, rules: [RequiredRule(), AlphaNumericRule()])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveProduction(_ sender: UIButton) {
        validator.validate(self)
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }

}

extension ProductionLocationViewController: ValidationDelegate {
    func validationSuccessful() {
        production.storyLocationName = storyLocationNameTextField.text!
        
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
