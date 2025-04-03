//
//  LoginViewController.swift
//  AccionTvContinuity
//
//  Created by 525 on 22/11/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var versionLbl: UILabel!
    var userHasToken = false
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
        
        
        versionLbl.text = "Version: \(Bundle.main.releaseVersionNumber!) (\(Bundle.main.buildVersionNumber!))"
        
        print("TOKEN")
        print(UserDefaults.standard.string(forKey: Identifier.Token))
        
        if (UserDefaults.standard.string(forKey: Identifier.Token)) != nil {
            userHasToken = true
            print("\t user has token")
            token = UserDefaults.standard.string(forKey: Identifier.Token)!
            print(UserDefaults.standard.string(forKey: Identifier.Token)!)
           // performSegue(withIdentifier: Identifier.Home, sender: self)
        } else {
            userHasToken = false
            UserDefaults.standard.removeObject(forKey: "app_token")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        performSegue(withIdentifier: Identifier.WebView, sender: self)
    }
    
}

// MARK: - Navigation

extension LoginViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.Home {
            let navigation = segue.destination as! UINavigationController
            let homeVC = navigation.topViewController as! MainMenuViewController
            homeVC.token = UserDefaults.standard.string(forKey: Identifier.Token)
        }
    }
    
    @IBAction func unwindToLoginVC(segue: UIStoryboardSegue) {
        
    }
}

// Mark: - Extension

extension LoginViewController {
    struct Identifier {
        static let Home = "Go Home"
        static let Token = "app_token"
        static let WebView = "Login Webview"
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}


