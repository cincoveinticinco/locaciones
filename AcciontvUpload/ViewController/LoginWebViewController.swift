//
//  LoginWebViewController.swift
//  AccionTvContinuity
//
//  Created by 525 on 22/11/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import WebKit

class LoginWebViewController: UIViewController {
    
    //@IBOutlet weak var wkLoginWebView: WKWebView!
    @IBOutlet weak var wkLoginWebView: WKWebView!
    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var closeButton: UIButton!
    
    var activityView: UIActivityIndicatorView?
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("API URL:", Urls.Login)
        
        let url = URL(string: Urls.Login)
        let request = URLRequest(url: url!)
        
        closeButton.isHidden = true
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityView?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityView?.color = #colorLiteral(red: 0.9538540244, green: 0.2200518847, blue: 0.3077117205, alpha: 1)
        activityView?.center = self.view.center
        activityView?.startAnimating()
        self.view.addSubview(activityView!)
        
        wkLoginWebView.navigationDelegate = self
        wkLoginWebView.load(request)
        
        //loginWebView.delegate = self
        //loginWebView.loadRequest(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeLoginWebView(_ sender: UIButton) {
        performSegue(withIdentifier: Identifier.GoBack, sender: self)
    }
    
}

// MARK: - WK Web View Delegate

extension LoginWebViewController: WKNavigationDelegate {
    
    func wkGetUserToken(webView: WKWebView){
        
      if let url = webView.url?.absoluteString {
            
            print("olal", url)
            
            if url.contains("/user/") {
                let index = url.range(of: "/user/")
                let convertedToken = url[(index?.upperBound)!..<url.endIndex]
                token = String(convertedToken)
                print("TOKEN USER", token)
            }else{
                token = nil
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if webView.isLoading {
            closeButton.isHidden = true
            webView.isHidden = true
            
            activityView?.startAnimating()
            wkGetUserToken(webView: webView)
            return
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.isHidden = false
        closeButton.isHidden = false
        
        wkGetUserToken(webView: webView)
        
        if((token) != nil){
            performSegue(withIdentifier: Identifier.Home, sender: self)
        }else{
            webView.getCookies(){ cookies in
                if let accionTok = cookies["accionTok"] as? [String: Any]{
                    if let convertedToken = accionTok["Value"] as? String  {
                        print("COOKIE ", convertedToken)
                        self.token = convertedToken
                    }
                }
            }
        }
        
        self.activityView?.hidesWhenStopped = true
        self.activityView?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail: WKNavigation!, withError: Error){
        performSegue(withIdentifier: Identifier.GoBack, sender: self)
    }
}

// MARK: - Web View Delegate

extension LoginWebViewController: UIWebViewDelegate {
    
    func getUserToken(webView: UIWebView){
        if let url = webView.request?.url?.absoluteString {
            if url.contains("/user/") {
                let index = url.range(of: "/user/")
                let convertedToken = url[(index?.upperBound)!..<url.endIndex]
                token = String(convertedToken)
               
            }
            
           
        }
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if webView.isLoading {
            closeButton.isHidden = true
            webView.isHidden = true
            
            activityView?.startAnimating()
            getUserToken(webView: webView)
            return
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        webView.isHidden = false
        closeButton.isHidden = false
        
        getUserToken(webView: webView)
        
        if((token) != nil){
            performSegue(withIdentifier: Identifier.Home, sender: self)
        }
        
        self.activityView?.hidesWhenStopped = true
        self.activityView?.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        performSegue(withIdentifier: Identifier.GoBack, sender: self)
    }
}

// MARK: - Navigation

extension LoginWebViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifier.Home {
            let navigation = segue.destination as! UINavigationController
            let homeVC = navigation.topViewController as! MainMenuViewController
            homeVC.token = token
            UserDefaults.standard.set(token!, forKey: Identifier.Token)
            UserDefaults.standard.synchronize()
        }
    }
}


// MARK: - Extension

extension LoginWebViewController {
    
    struct Identifier {
        static let GoBack = "unwindToLoginVC"
        static let Menu = "Show Menu"
        static let Home = "App Home"
        static let Token = "app_token"
    }
    
    struct Urls {
        static let Login =  UserDefaults.standard.string(forKey: SettingsBundleHelper.SettingsBundleKeys.ServerURL)! + "/saml/init"
    }
}

// MARK: - GET COOKIES WEB VIEW
extension WKWebView {

    private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }

    func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
        var cookieDict = [String : AnyObject]()
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                } else {
                    cookieDict[cookie.name] = cookie.properties as AnyObject?
                }
            }
            completion(cookieDict)
        }
    }
}
