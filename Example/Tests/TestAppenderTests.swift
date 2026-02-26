//
//  TestAppenderTests.swift
//  ShipBookSDK-Tests
//
//  Created by Elisha Sterngold on 24/02/2026.
//  Copyright © 2026 ShipBook Ltd. All rights reserved.
//

import XCTest
@testable import ShipBookSDK

class TestAppenderTests: XCTestCase {

  class TestAppender: BaseAppender {
    var name: String
    var logs: [BaseLog] = []
    var messages: [Message] { logs.compactMap { $0 as? Message } }
    var exceptions: [Exception] { logs.compactMap { $0 as? Exception } }

    required init(name: String, config: Config?) {
      self.name = name
    }

    func update(config: Config?) {}

    func push(log: BaseLog) {
      logs.append(log)
    }

    func flush() {}

    func saveCrash(exception: Exception) {}

    func clear() {
      logs.removeAll()
    }
  }

  var testAppender: TestAppender!

  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    testAppender = TestAppender(name: "test", config: nil)
    LogManager.shared.clear()

    let exp = expectation(description: "setup")
    LogManager.shared.add(appender: testAppender, name: "test")
    LogManager.shared.add(module: "", severity: .Verbose, callStackSeverity: .Off, appender: "test")
    DispatchQueue.shipBook.async {
      exp.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  override func tearDown() {
    LogManager.shared.clear()
    super.tearDown()
  }

  func testPushMessageReceived() {
    let log = Log("TestTag")
    log.e("test error message")

    let exp = expectation(description: "push")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(self.testAppender.messages.count, 1)
      let msg = self.testAppender.messages[0]
      XCTAssertEqual(msg.message, "test error message")
      XCTAssertEqual(msg.severity, .Error)
      XCTAssertEqual(msg.tag, "TestTag")
      exp.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testAllSeverityLevels() {
    let log = Log("TestTag")
    log.e("error")
    log.w("warning")
    log.i("info")
    log.d("debug")
    log.v("verbose")

    let exp = expectation(description: "severities")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(self.testAppender.messages.count, 5)
      XCTAssertEqual(self.testAppender.messages[0].severity, .Error)
      XCTAssertEqual(self.testAppender.messages[1].severity, .Warning)
      XCTAssertEqual(self.testAppender.messages[2].severity, .Info)
      XCTAssertEqual(self.testAppender.messages[3].severity, .Debug)
      XCTAssertEqual(self.testAppender.messages[4].severity, .Verbose)
      exp.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testSeverityFiltering() {
    LogManager.shared.clear()
    let exp1 = expectation(description: "setup-filter")
    let filterAppender = TestAppender(name: "filter", config: nil)
    LogManager.shared.add(appender: filterAppender, name: "filter")
    LogManager.shared.add(module: "", severity: .Warning, callStackSeverity: .Off, appender: "filter")
    DispatchQueue.shipBook.async {
      exp1.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let log = Log("TestTag")
    log.e("error")
    log.w("warning")
    log.i("info should be filtered")
    log.d("debug should be filtered")
    log.v("verbose should be filtered")

    let exp2 = expectation(description: "check-filter")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(filterAppender.messages.count, 2)
      XCTAssertEqual(filterAppender.messages[0].message, "error")
      XCTAssertEqual(filterAppender.messages[1].message, "warning")
      exp2.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testTagBasedRouting() {
    LogManager.shared.clear()
    let uiAppender = TestAppender(name: "ui", config: nil)
    let dataAppender = TestAppender(name: "data", config: nil)

    let exp1 = expectation(description: "setup-routing")
    LogManager.shared.add(appender: uiAppender, name: "ui")
    LogManager.shared.add(appender: dataAppender, name: "data")
    LogManager.shared.add(module: "UI", severity: .Verbose, callStackSeverity: .Off, appender: "ui")
    LogManager.shared.add(module: "Data", severity: .Verbose, callStackSeverity: .Off, appender: "data")
    DispatchQueue.shipBook.async {
      exp1.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let uiLog = Log("UI.ViewController")
    let dataLog = Log("Data.Repository")
    uiLog.i("ui message")
    dataLog.i("data message")

    let exp2 = expectation(description: "check-routing")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(uiAppender.messages.count, 1)
      XCTAssertEqual(uiAppender.messages[0].message, "ui message")
      XCTAssertEqual(dataAppender.messages.count, 1)
      XCTAssertEqual(dataAppender.messages[0].message, "data message")
      exp2.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testNonMessageLog() {
    let screenEvent = ScreenEvent(name: "TestScreen")
    LogManager.shared.push(log: screenEvent)

    let exp = expectation(description: "non-message")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(self.testAppender.logs.count, 1)
      XCTAssertEqual(self.testAppender.messages.count, 0)
      XCTAssertTrue(self.testAppender.logs[0] is ScreenEvent)
      exp.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testRegisterCustomAppender() {
    AppenderFactory.register(type: "TestAppender", appenderClass: TestAppender.self)

    let configString = """
    {
      "appenders": [
        { "type": "TestAppender", "name": "custom" }
      ],
      "loggers": [
        { "severity": "Verbose", "appenderRef": "custom" }
      ]
    }
    """

    var config: ConfigResponse?
    XCTAssertNoThrow(config = try ConnectionClient.jsonDecoder.decode(
      ConfigResponse.self,
      from: configString.data(using: .utf8)!
    ))

    LogManager.shared.config(config!)
    let exp = expectation(description: "register")
    DispatchQueue.shipBook.async {
      let appender = LogManager.shared.appenders["custom"]
      XCTAssertNotNil(appender)
      XCTAssertTrue(appender is TestAppender)

      let log = Log("TestTag")
      log.i("registered appender test")

      DispatchQueue.shipBook.async {
        let customAppender = LogManager.shared.appenders["custom"] as! TestAppender
        XCTAssertEqual(customAppender.messages.count, 1)
        XCTAssertEqual(customAppender.messages[0].message, "registered appender test")
        exp.fulfill()
      }
    }
    waitForExpectations(timeout: 2, handler: nil)
  }

  func testMessageContainsCallerInfo() {
    let log = Log("TestTag")
    log.e("caller info test")

    let exp = expectation(description: "caller-info")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(self.testAppender.messages.count, 1)
      let msg = self.testAppender.messages[0]
      XCTAssertFalse(msg.function.isEmpty)
      XCTAssertFalse(msg.file.isEmpty)
      XCTAssertGreaterThan(msg.line, 0)
      exp.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }

  func testCallStackSeverity() {
    LogManager.shared.clear()
    let exp1 = expectation(description: "setup-callstack")
    let stackAppender = TestAppender(name: "stack", config: nil)
    LogManager.shared.add(appender: stackAppender, name: "stack")
    LogManager.shared.add(module: "", severity: .Verbose, callStackSeverity: .Error, appender: "stack")
    DispatchQueue.shipBook.async {
      exp1.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)

    let log = Log("TestTag")
    log.e("error with stack")
    log.i("info without stack")

    let exp2 = expectation(description: "check-callstack")
    DispatchQueue.shipBook.async {
      XCTAssertEqual(stackAppender.messages.count, 2)
      XCTAssertNotNil(stackAppender.messages[0].callStackSymbols)
      XCTAssertNil(stackAppender.messages[1].callStackSymbols)
      exp2.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
  }
}
