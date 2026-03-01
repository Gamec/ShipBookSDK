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
    ShipBook.enableInnerLog(enable: true)

    let info = Bundle.main.infoDictionary!
    let appId = info["SHIPBOOK_APP_ID"] as! String
    let appKey = info["SHIPBOOK_APP_KEY"] as! String
    if let url = info["SHIPBOOK_URL"] as? String, !url.isEmpty {
      ShipBook.setConnectionUrl(url)
    }

    // Start with completion to get session URL
    ShipBook.start(appId: appId, appKey: appKey, completion: { sessionUrl in
      print("ShipBook session URL: \(sessionUrl)")
    })

    // Programmatic window setup (no storyboard)
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = UINavigationController(rootViewController: ViewController())
    window?.makeKeyAndVisible()

    return true
  }
}
