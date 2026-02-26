//
//  Exception.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 15/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation

public struct BinaryImage: Codable {
  public var startAddress: String
  public var name: String
  public var arch: String
  public var path: String
  init(startAddress: String, name: String, arch: String, path: String) {
    self.startAddress = startAddress
    self.name = name
    self.arch = arch
    self.path = path
  }
}

public class Exception : BaseLog  {
  public var name: String
  public var reason: String? = nil
  //var userInfo: [AnyHashable : Any]?
  public var callStackSymbols: [String]?
  public var binaryImages: [BinaryImage]?

  
  public init(name: String, reason: String? = nil, callStackSymbols: [String]? = nil, binaryImages: [BinaryImage]? = nil) {
    self.name = name
    self.reason = reason
//    self.threadInfo = ThreadInfo()
    self.callStackSymbols = callStackSymbols
    self.binaryImages = binaryImages
    super.init(type:"exception")
  }

  enum CodingKeys: String, CodingKey {
    case name
    case reason
    case callStackSymbols
    case binaryImages
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.reason = try container.decodeIfPresent(String.self, forKey: .reason)
    self.callStackSymbols = try container.decodeIfPresent(Array.self, forKey: .callStackSymbols)
    self.binaryImages = try container.decodeIfPresent(Array.self, forKey: .binaryImages )
    try super.init(from: decoder)
  }
  
  public override func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(reason, forKey: .reason)
    try container.encodeIfPresent(callStackSymbols, forKey: .callStackSymbols)
    try container.encodeIfPresent(binaryImages, forKey: .binaryImages)
    try super.encode(to: encoder)
  }
}

func ==(lhs: Exception, rhs: Exception) -> Bool {
  return lhs.time.toISO8601Format() == rhs.time.toISO8601Format() &&
    lhs.name == rhs.name &&
    lhs.reason == rhs.reason &&
    // TODO: add stackTrace
//    (lhs.stackTrace?)! == (rhs.stackTrace?)! &&
    lhs.threadInfo == rhs.threadInfo 
}


