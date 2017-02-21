//
//  AppDelegate.swift
//  OKJUX
//
//  Created by German Pereyra on 2/8/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController: UIViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        updateAppSettingsVersion()

        #if DEBUG
            for arg in ProcessInfo.processInfo.arguments {
                if arg.contains("Mock-") {
                    MockRequestHelper.mockAppByString(arg)
                    break
                }
            }
        #endif


        UserManager.sharedInstance.registerUser(uuid: UserHelper.getUUID()) { (error) in
            if let _ = error {
                //TODO: Show error
            } else {
                //TODO: Present landing

                MockRequestHelper.mockRequest(path: "/api/v1/snaps", responseFile: "get_snaps_mock")
                self.mainViewController = SnapsViewController()
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let navigationController = UINavigationController(rootViewController: self.mainViewController)
                navigationController.isNavigationBarHidden = true
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func updateAppSettingsVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            UserDefaults.standard.setValue(String(format: "%@(%@)", version, buildVersion), forKey: "version_number")
            UserDefaults.standard.synchronize()
        }
    }

}
