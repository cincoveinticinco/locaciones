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
    @IBOutlet weak var loginButton: UIButton!
    var userHasToken = false
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsBundleHelper.checkAndExecuteSettings()
        applyEnvironmentStyle()
        
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyEnvironmentStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        performSegue(withIdentifier: Identifier.WebView, sender: self)
    }
    
}

// MARK: - Environment Style

extension LoginViewController {
    private func applyEnvironmentStyle() {
        let env = SettingsBundleHelper.getEnvironment()
        let version = Bundle.main.releaseVersionNumber ?? ""
        let build = Bundle.main.buildVersionNumber ?? ""

        if env == "Production" {
            versionLbl.text = "VERSION \(version) (\(build))"
            return
        }

        versionLbl.text = "VERSION \(version) (\(build)) - \(env)"

        switch env {
        case "Testing":
            view.backgroundColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 1)
            loginButton.backgroundColor = UIColor(red: 24/255, green: 106/255, blue: 59/255, alpha: 1)
        case "Staging":
            view.backgroundColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1)
            loginButton.backgroundColor = UIColor(red: 23/255, green: 82/255, blue: 121/255, alpha: 1)
        case "Development":
            view.backgroundColor = UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)
            loginButton.backgroundColor = UIColor(red: 175/255, green: 96/255, blue: 26/255, alpha: 1)
        case "Local":
            view.backgroundColor = UIColor(red: 142/255, green: 68/255, blue: 173/255, alpha: 1)
            loginButton.backgroundColor = UIColor(red: 91/255, green: 44/255, blue: 111/255, alpha: 1)
        default:
            break
        }
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
