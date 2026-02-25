//
//  AppDelegate.swift
//  ShipBookSDK
//
//  Created by Elisha Sterngold on 01/21/2018.
//  Copyright (c) 2018 ShipBook Ltd. All rights reserved.
//

import UIKit
import ShipBookSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Override point for customization after application launch.
      ShipBook.enableInnerLog(enable: true)
      #if compiler(>=6.1)
      print("Hello, Swift 6.1")
      #elseif compiler(>=6.0)
      print("Hello, Swift 6.0")
      #elseif compiler(>=5.10)
      print("Hello, Swift 5.10")
      #elseif compiler(>=5.9)
      print("Hello, Swift 5.9")
      #else
      print("Hello, Swift 5.x")
      #endif

      let info = Bundle.main.infoDictionary!
      let appId = info["SHIPBOOK_APP_ID"] as! String
      let appKey = info["SHIPBOOK_APP_KEY"] as! String
      if let url = info["SHIPBOOK_URL"] as? String, !url.isEmpty {
          ShipBook.setConnectionUrl(url)
      }
      ShipBook.start(appId: appId, appKey: appKey)
      return true
    }
  
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

