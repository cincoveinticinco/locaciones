//
//  AppDelegate.swift
//  AcciontvUpload
//
//  Created by 525 on 29/8/17.
//  Copyright © 2017 525. All rights reserved.
//

import UIKit
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var reachability: Reachability = Reachability()
    let reachability = try! Reachability()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: Notification.Name.reachabilityChanged, object: reachability)
        NotificationCenter.default.addObserver(self, selector: #selector(defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Load login App Screen
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateInitialViewController() as! LoginViewController
        self.window?.rootViewController = loginVC
        self.window?.makeKeyAndVisible()
        
        if loginVC.userHasToken {
            let mainVC = storyboard.instantiateViewController(withIdentifier: "Main Navigation") as! UINavigationController
            let homeVC = mainVC.topViewController as! MainMenuViewController
            homeVC.token = loginVC.token
            mainVC.modalPresentationStyle = .fullScreen
            //loginVC.navigationController?.pushViewController(mainVC, animated: true)
            loginVC.present(mainVC, animated: true, completion: nil)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
        SettingsBundleHelper.checkAndExecuteSettings()
        SettingsBundleHelper.setVersionAndBuildNumber()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    @objc func reachabilityChanged(notification:Notification){
        print("reachabilityChanged reachabilityChanged reachabilityChanged reachabilityChanged")

        let reachability = notification.object as! Reachability
        
        
        if reachability.connection == .wifi{
            print("Reachable via WiFi")
            Queue.taskQueue.main.run()
        }else if reachability.connection == .cellular{
            print("Reachable via Cellular")
            Queue.taskQueue.main.run()
        }else{
            print("Network not reachable")
        }
        
       /* switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            Queue.taskQueue.main.run()
        case .cellular:
            print("Reachable via Cellular")
            Queue.taskQueue.main.run()
        case .unavailable:
            print("Network not reachable")
        }*/
    }
    
    @objc func defaultsChanged(){
//        if UserDefaults.standard.bool(forKey: "RedThemeKey") {
//            self.view.backgroundColor = UIColor.red
//        }
//        else {
//            self.view.backgroundColor = UIColor.green
//        }
        print("\n\nDefault changed current value: \(UserDefaults.standard.string(forKey: "server_url"))")
    }
    
    func getReachability() -> Reachability {
        return reachability
    }
}

