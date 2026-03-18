//
//  SettingsBundleHelper.swift
//  AcciontvUpload
//
//  Created by 525 on 30/1/18.
//  Copyright © 2018 525. All rights reserved.
//

import Foundation

class SettingsBundleHelper {
    
    class func checkAndExecuteSettings() {
        if (UserDefaults.standard.string(forKey: SettingsBundleKeys.ServerURL) == nil) {
            UserDefaults.standard.set("https://prod.acciontv.com/api/", forKey: SettingsBundleKeys.ServerURL)
        }
//        if UserDefaults.standard.bool(forKey: SettingsBundleKeys.ServerURL) {
//            UserDefaults.standard.set(false, forKey: SettingsBundleKeys.ServerURL)
//            let appDomain: String? = Bundle.main.bundleIdentifier
//            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
//            // reset userDefaults..
//            // CoreDataDataModel().deleteAllData()
//            // delete all other user data here..
//        }
        
    }
    
    class func setVersionAndBuildNumber() {
        let version: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        UserDefaults.standard.set(version, forKey: "version_preference")
    }
    
    class func getEnvironment() -> String {
        let url = UserDefaults.standard.string(forKey: SettingsBundleKeys.ServerURL) ?? ""
        if url.contains("testing")  { return "Testing" }
        if url.contains("staging")  { return "Staging" }
        if url.contains("development") { return "Development" }
        if url.contains("10.10.31") { return "Local" }
        return "Production"
    }
    
    struct SettingsBundleKeys {
        static let ServerURL = "server_url"
        static let Camera = "camera_enabled"
        static let AppVersionKey = "version_preference"
    }
}
