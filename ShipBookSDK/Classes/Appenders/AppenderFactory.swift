//
//  AppenderFactory.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 07/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//
#if canImport(UIKit)
import Foundation

struct AppenderFactory {
  struct FactoryError : Error {
  }

  private static var registry: [String: BaseAppender.Type] = [:]

  static func register(type: String, appenderClass: BaseAppender.Type) {
    registry[type] = appenderClass
  }

  static func create(type: String, name: String, config: Config?) throws -> BaseAppender {
    if let appenderType = registry[type] {
      return appenderType.init(name: name, config: config)
    }
    switch type {
    case "ConsoleAppender":
      return ConsoleAppender(name: name, config: config)
//    case "OsLogAppender":
//      return OsLogAppender(name: name, config: config)
    case "SLCloudAppender", "SBCloudAppender": // SLCloudAppender for backward compatibility
      return SBCloudAppender(name: name, config: config)

    default:
      throw FactoryError()
    }
  }
}
#endif
