//
//  UserMenuTableViewController.swift
//  AcciontvUpload
//
//  Created by 525 on 30/1/18.
//  Copyright © 2018 525. All rights reserved.
//

import UIKit

class UserMenuTableViewController: UITableViewController {
    
    var token: String?
    var user: User?
    var that = self

    override func viewDidLoad() {
        super.viewDidLoad()
        token = UserDefaults.standard.string(forKey: "app_token")
        
        if user == nil {
            user = User()
            user?.name = "JOSE"
            user?.lastName = "Last name"
            user?.sso = 1111
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Menu User", for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = user!.name!.uppercased() + " " + user!.lastName!.uppercased() + " (\(user!.sso!))"
        case 1:
            cell.textLabel?.text = NSLocalizedString("CLOSE SESSION", comment: "")
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            closeSession()
            self.performSegue(withIdentifier: "unwindToLoginVC", sender: self)
            UserDefaults.standard.removeObject(forKey: "app_token")
            
        }
    }
    
    func closeSession() {
        let cookieJar = HTTPCookieStorage.shared

        for cookie in cookieJar.cookies! {
            print(cookie.name+"="+cookie.value)
            cookieJar.deleteCookie(cookie)
        }
        
        let serverURL = UserDefaults.standard.string(forKey: "server_url")
        let url = URL(string: "\(serverURL!)/saml/logout/1/\(token!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        LocationData.data.deleteJSONDataFromDisk();
        LocationData.data.destroyDB();
        
        
       NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
        print(url)
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
       }

    }

}
