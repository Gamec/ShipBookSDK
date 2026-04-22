//
//  Login.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 05/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//
import Foundation

struct Login : Codable {
  let appId: String
  let appKey: String
  let bundleIdentifier: String
  let appName: String
  let udid: String
  let time: Date
  var deviceTime: Date // the device time in the time of the login request
#if os(iOS)
  let os: String = "ios"
#elseif os(tvOS)
  let os: String = "tvos"
#elseif os(macOS)
  let os: String = "macos"
#elseif os(watchOS)
  let os: String = "watchos"
#elseif os(visionOS)
  let os: String = "visionos"
#else
  let os: String = "unknown"
#endif
  let osVersion: String
  let appVersion: String
  let appBuild: String
  let sdkVersion: String
  let manufacturer: String = "apple"
  let deviceName: String
  let deviceModel: String
  let language: String
  var isDebug: Bool? = nil
  var user: User?
  
  init(appId: String, appKey: String) {
    self.appId = appId
    self.appKey = appKey
    
    udid = DeviceInfo.identifierForVendor
    time = Date()
    deviceTime = time
    bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    osVersion = DeviceInfo.osVersion
    appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    sdkVersion = shipBookSDKVersion
    deviceName = DeviceInfo.deviceName
    deviceModel = DeviceInfo.modelName
    language = "\(Locale.current.languageCode ?? "")-\(Locale.current.regionCode ?? "")"
  #if DEBUG
    isDebug = true
  #endif
  }

  enum CodingKeys: String, CodingKey {
    case appId
    case appKey
    case bundleIdentifier
    case appName
    case udid
    case time
    case deviceTime
    
    case os
    case osVersion
    case appVersion
    case appBuild
    case sdkVersion
    case manufacturer
    case deviceName
    case deviceModel
    case language
    case isDebug
    case user
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.appId = try container.decode(String.self, forKey: .appId)
    self.appKey = try container.decode(String.self, forKey: .appKey)
    self.bundleIdentifier = try container.decode(String.self, forKey: .bundleIdentifier)
    self.appName = try container.decode(String.self, forKey: .appName)
    self.udid = try container.decode(String.self, forKey: .udid)
    let time = try container.decode(String.self, forKey: .time)
    self.time = try time.toDate()
    let deviceTime = try container.decode(String.self, forKey: .deviceTime)
    self.deviceTime = try deviceTime.toDate()
    
    // self.os - is initialized with let
    self.osVersion = try container.decode(String.self, forKey: .osVersion)
    self.appVersion = try container.decode(String.self, forKey: .appVersion)
    self.appBuild = try container.decode(String.self, forKey: .appBuild)
    self.sdkVersion = try container.decode(String.self, forKey: .sdkVersion)
    // self.manufacturer - is initialized with let
    self.deviceName = try container.decode(String.self, forKey: .deviceName)
    self.deviceModel = try container.decode(String.self, forKey: .deviceModel)
    self.language = try container.decode(String.self, forKey: .language)
    self.isDebug = try container.decodeIfPresent(Bool.self, forKey: .isDebug)
    self.user = try container.decodeIfPresent(User.self, forKey: .user)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(appId, forKey: .appId)
    try container.encode(appKey, forKey: .appKey)
    try container.encode(bundleIdentifier, forKey: .bundleIdentifier)
    try container.encode(appName, forKey: .appName)
    try container.encode(udid, forKey: .udid)
    try container.encode(time.toISO8601Format(), forKey: .time)
    try container.encode(deviceTime.toISO8601Format(), forKey: .deviceTime)
    try container.encode(os, forKey: .os)
    try container.encode(osVersion, forKey: .osVersion)
    try container.encode(appVersion, forKey: .appVersion)
    try container.encode(appBuild, forKey: .appBuild)
    try container.encode(sdkVersion, forKey: .sdkVersion)

    try container.encode(manufacturer, forKey: .manufacturer)
    try container.encode(deviceName, forKey: .deviceName)
    try container.encode(deviceModel, forKey: .deviceModel)
    try container.encode(language, forKey: .language)
    
    try container.encodeIfPresent(isDebug, forKey: .isDebug)
    try container.encodeIfPresent(user, forKey: .user)
  }
}

extension Login: Equatable {}

func ==(lhs: Login, rhs: Login) -> Bool {
  return lhs.appId == rhs.appId &&
    lhs.appKey == rhs.appKey &&
    lhs.udid == rhs.udid &&
    lhs.time.toISO8601Format() == rhs.time.toISO8601Format() &&
    lhs.deviceTime.toISO8601Format() == rhs.deviceTime.toISO8601Format() &&
    lhs.os == rhs.os &&
    lhs.osVersion == rhs.osVersion &&
    lhs.appVersion == rhs.appVersion &&
    lhs.appBuild == rhs.appBuild &&
    lhs.sdkVersion == rhs.sdkVersion &&
    lhs.manufacturer == rhs.manufacturer &&
    lhs.deviceModel == rhs.deviceModel &&
    lhs.deviceName == rhs.deviceName &&
    lhs.language == rhs.language
}
