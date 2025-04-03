//
//  MainMenuViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 18/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import SwiftyJSON

class MainMenuViewController: UIViewController {
    
    var token: String?
    var user: User?
    var alert: UIAlertController?

    @IBOutlet weak var uploadingListButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("en el menu")
        
        uploadingListButton.setTitle(NSLocalizedString("UPLOADING LIST", comment: ""), for: .normal)
        configureNavigationIcons()
        startRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("==========================================")
        print(UserDefaults.standard.string(forKey: "app_token") )
        print("==========================================")
//        if UserDefaults.standard.string(forKey: "app_token") == nil {
//            performSegue(withIdentifier: Identifier.GoBack, sender: self)
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if alert != nil {
           self.present(alert!, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue) {
        print("unwindToMainMenu")
        if let _ = sender.source as? CreationViewController {
            
        }
    }
    
    // MARK: - Miscellaneous
    func startRequest() {
        let accionRequest = AccionRequest("POST", [AccionRequest.AccionKey.Session:token!], "/saml/validate_session")
        let req = accionRequest.setupRequest()
        accionRequest.fetchData(request: req, completionHander: {
            (response: JSON) in
            if response == JSON.null {
                print("se vino por aqui")
                print(self.token!)
                UserDefaults.standard.set(nil, forKey: "app_token")
                self.performSegue(withIdentifier: Identifier.GoBack, sender: self)
            } else {
                self.saveValidation(json: response)
            }
        })
    }
    
    func saveValidation(json: JSON) {
        if json["noaccess"].string == "Session Inactive" {
            UserDefaults.standard.set(nil, forKey: "app_token")
            self.performSegue(withIdentifier: Identifier.GoBack, sender: self)
        }
        print(json)
        let user = json[Identifier.User].arrayValue.map {$0.dictionaryObject}
        let secureModule = json["secure_modules"].arrayValue.map {$0.dictionaryObject}
        print(user)
        if !user.isEmpty && !secureModule.isEmpty {
            for u in user {
                let userSession = User()
                userSession.name = u!["user_name"] as? String ?? "Default"
                userSession.lastName = u!["user_last_name"] as? String ?? "User"
                userSession.email = u!["email"] as? String ?? "default@mail.com"
                userSession.language = u!["language"] as? String ?? "es"
                userSession.sso = u!["sso"] as? Int ?? 1111
                
                let access: Int = (secureModule[38]!["access"] as? Int)!
                print(access)
                
                if access == 2 {
                    self.user = userSession
                } else {
                    closeSession()
                    showNoaccess()
                }
            }
        } else {
            closeSession()
            showNoaccess()
        }
        
        
    }
    
    func showNoaccess() {
        let alert = UIAlertController(title: NSLocalizedString("NO ACCESS", comment: ""), message: NSLocalizedString("You have no access to this module", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: {
            action in
            UserDefaults.standard.set(nil, forKey: "app_token")
            self.performSegue(withIdentifier: Identifier.GoBack, sender: self)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func closeSession() {
        let serverURL = UserDefaults.standard.string(forKey: "server_url")
        let url = URL(string: "\(serverURL!)/saml/logout/1/\(token!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        LocationData.data.deleteJSONDataFromDisk();
        LocationData.data.destroyDB();
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            print(url)
            
        }
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
        alert = nil
        self.present(popoverContent, animated: true, completion: nil)
    }
}

extension MainMenuViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("------- INIT SEGUE ---------")
        print(segue.identifier)
        if segue.identifier == Identifier.Location {
            if let createLocationVC = segue.destination as? CreationViewController {
                createLocationVC.token = token
                createLocationVC.user = user
            }
        }  else if segue.identifier == Identifier.ToUpload {
            if let tasksVC = segue.destination as? TasksQueueViewController {
                tasksVC.user = user
            }
        }
        alert = nil
    }
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    func configureNavigationIcons() {

        let userButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 44))
        userButtonView.backgroundColor = #colorLiteral(red: 0.9920430779, green: 0.2019116879, blue: 0.3119246364, alpha: 1)

        let userButton = UIButton(frame: CGRect(x: 16, y: 12, width: 25, height: 22))
        userButton.setImage(#imageLiteral(resourceName: "User Settings Icon"), for: UIControlState.normal)
        userButton.addTarget(self, action: #selector(openMenu(_:)), for: .touchUpInside)
        userButtonView.addSubview(userButton)
        
        let spacerNegative = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerNegative.width = -20.0
        
        let redColor = #colorLiteral(red: 0.9920430779, green: 0.2019116879, blue: 0.3119246364, alpha: 1)
        let attributedLanguageTitle = NSMutableAttributedString(string: "ESP/ENG")
        attributedLanguageTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: redColor, range: NSRange(location:4, length: 3))
        attributedLanguageTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: 4))
        attributedLanguageTitle.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Cabin-Medium", size: 14)!, range: NSRange(location: 0, length: 7))
        
        let languageButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 45))
        let mySelectedAttributedTitle = NSAttributedString(string: "ESP",
                                                           attributes: [NSAttributedStringKey.foregroundColor : UIColor.cyan])
        languageButton.setAttributedTitle(mySelectedAttributedTitle, for: .selected)
        let myNormalAttributedTitle = attributedLanguageTitle
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 45))
        buttonView.addSubview(languageButton)
        languageButton.setAttributedTitle(myNormalAttributedTitle, for: .normal)
        
        let userButtonItem = UIBarButtonItem(customView: userButtonView)
        
        self.navigationItem.setRightBarButtonItems([userButtonItem, spacerNegative], animated: true)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    @objc func openMenu(_ sender: UIButton?) {
        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "User Menu") as! UserMenuTableViewController
        
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
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension MainMenuViewController {
    struct Identifier {
        static let GoBack = "unwindToLoginVC"
        static let Location = "Create Location"
        static let Home = "App Home"
        static let UserMenu = "User Menu"
        static let ToUpload = "To Upload"
        static let Token = "token"
        static let User = "user"
    }
}
