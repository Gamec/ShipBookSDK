//
//  BaseLog.swift
//  ShipBook
//
//  Created by Elisha Sterngold on 20/11/2017.
//  Copyright © 2018 ShipBook Ltd. All rights reserved.
//

import Foundation

public class BaseLog: Codable  {
  static var dispatchQueue = DispatchQueue(label: "io.shipbook.counter")
  static var count: Int = 0
  
  public var time: Date
  public var orderId: Int
  public var threadInfo: ThreadInfo
  public var type: String
  
  init(type: String) {
    self.type = type
    time = Date()
    threadInfo = ThreadInfo()
    self.orderId =  0
    BaseLog.dispatchQueue.sync {
      BaseLog.count += 1
      self.orderId = BaseLog.count
    }
  }
  
  enum BaseCodingKeys: String, CodingKey {
    case time
    case orderId
    case threadInfo
    case type
  }
  
  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: BaseCodingKeys.self)
    let time = try container.decode(String.self, forKey: .time)
    self.time = try time.toDate()
    self.orderId = try container.decode(Int.self, forKey: .orderId)
    self.threadInfo = try container.decode(ThreadInfo.self, forKey: .threadInfo)
    self.type = try container.decode(String.self, forKey: .type)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: BaseCodingKeys.self)
    try container.encode(time.toISO8601Format(), forKey: .time)
    try container.encode(orderId, forKey: .orderId)
    try container.encode(threadInfo, forKey: .threadInfo)
    try container.encode(type, forKey: .type)
  }

}

public struct ThreadInfo: Codable {
  public var isMain: Bool
  public var queueLabel: String
  public var threadName: String
  public var threadId: UInt64
  init (){
    isMain = Thread.current.isMainThread
    queueLabel = DispatchQueue.currentLabel
    threadName = Thread.current.name ?? ""
    self.threadId = Thread.threadId
  }
}

extension ThreadInfo: Equatable {}
public func ==(lhs: ThreadInfo, rhs: ThreadInfo) -> Bool {
  return lhs.isMain == rhs.isMain &&
    lhs.queueLabel == rhs.queueLabel &&
    lhs.threadName == rhs.threadName &&
    lhs.threadId == rhs.threadId
}

extension BaseLog: Equatable {}

public func ==(lhs: BaseLog, rhs: BaseLog) -> Bool {
  return lhs.time.toISO8601Format() == rhs.time.toISO8601Format() &&
    lhs.threadInfo == rhs.threadInfo &&
    lhs.type == rhs.type
}


