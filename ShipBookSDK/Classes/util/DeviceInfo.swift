//
//  DeviceInfo.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 29/10/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
import IOKit
#endif

enum DeviceInfo {
  static var modelName: String {
#if os(macOS)
    return sysctlString(name: "hw.model") ?? machineName()
#else
    return machineName()
#endif
  }

  static var osVersion: String {
#if canImport(UIKit)
    return UIDevice.current.systemVersion
#else
    let v = ProcessInfo.processInfo.operatingSystemVersion
    return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
#endif
  }

  static var deviceName: String {
#if canImport(UIKit)
    return UIDevice.current.name
#else
    return Host.current().localizedName ?? ProcessInfo.processInfo.hostName
#endif
  }

  static var identifierForVendor: String {
#if canImport(UIKit)
    return UIDevice.current.identifierForVendor?.uuidString ?? ""
#elseif canImport(AppKit)
    return macPlatformUUID() ?? ""
#else
    return ""
#endif
  }

  private static func machineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
  }

#if os(macOS)
  private static func sysctlString(name: String) -> String? {
    var size = 0
    sysctlbyname(name, nil, &size, nil, 0)
    guard size > 0 else { return nil }
    var buffer = [CChar](repeating: 0, count: size)
    sysctlbyname(name, &buffer, &size, nil, 0)
    return String(cString: buffer)
  }

  private static func macPlatformUUID() -> String? {
    let platformExpert = IOServiceGetMatchingService(kIOMainPortDefault,
                                                     IOServiceMatching("IOPlatformExpertDevice"))
    guard platformExpert != 0 else { return nil }
    defer { IOObjectRelease(platformExpert) }
    guard let uuidProperty = IORegistryEntryCreateCFProperty(platformExpert,
                                                             kIOPlatformUUIDKey as CFString,
                                                             kCFAllocatorDefault,
                                                             0) else { return nil }
    return uuidProperty.takeRetainedValue() as? String
  }
#endif
}
