//
//  ViewController.swift
//  ShipBookSDK
//
//  Created by Elisha Sterngold on 01/21/2018.
//  Copyright (c) 2018 ShipBook Ltd. All rights reserved.
//

import UIKit
import ShipBookSDK

fileprivate let log = ShipBook.getLogger(ViewController.self)

class ViewController: UIViewController {

  // MARK: - State
  private var isUserRegistered = false
  private var userCounter = 0

  // MARK: - UI Elements
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  private var registerButton: UIButton!

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "ShipBook Example"
    view.backgroundColor = .systemBackground
    setupUI()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    ShipBook.screen(name: "ViewController")
  }

  // MARK: - UI Setup

  private func setupUI() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    stackView.axis = .vertical
    stackView.spacing = 12
    stackView.alignment = .center
    stackView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
      stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
      stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
    ])

    addUserManagementSection()
    addScreenTrackingSection()
    addDivider()
    addLogLevelsSection()
    addDivider()
    addAdvancedFeaturesSection()
    addDivider()
    addStressTestSection()
  }

  // MARK: - Sections

  private func addUserManagementSection() {
    addSectionLabel("User Management")

    registerButton = makeButton(title: "Register user [test0]", action: #selector(toggleUser))
    stackView.addArrangedSubview(registerButton)
  }

  private func addScreenTrackingSection() {
    addSectionLabel("Screen Tracking")

    let button = makeButton(title: "Set screen to Home", action: #selector(setScreen))
    stackView.addArrangedSubview(button)
  }

  private func addLogLevelsSection() {
    addSectionLabel("Log Levels")

    let row = UIStackView()
    row.axis = .horizontal
    row.spacing = 8
    row.distribution = .fillEqually

    let buttons: [(String, Selector)] = [
      ("Error", #selector(logError)),
      ("Warning", #selector(logWarning)),
      ("Info", #selector(logInfo)),
      ("Debug", #selector(logDebug)),
      ("Verbose", #selector(logVerbose)),
    ]
    for (title, sel) in buttons {
      row.addArrangedSubview(makeButton(title: title, action: sel))
    }

    row.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubview(row)
    row.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
  }

  private func addAdvancedFeaturesSection() {
    addSectionLabel("Advanced Features")

    stackView.addArrangedSubview(makeButton(title: "Log Exception", action: #selector(logException)))
    stackView.addArrangedSubview(makeButton(title: "Throw Uncaught Exception", action: #selector(throwUncaughtException)))
    stackView.addArrangedSubview(makeButton(title: "Flush Logs", action: #selector(flushLogs)))
  }

  private func addStressTestSection() {
    addSectionLabel("Stress Testing")

    stackView.addArrangedSubview(makeButton(title: "Race Condition Test (1000 threads)", action: #selector(raceConditionTest)))
  }

  // MARK: - Helpers

  private func addSectionLabel(_ text: String) {
    let label = UILabel()
    label.text = text
    label.font = .boldSystemFont(ofSize: 18)
    label.textAlignment = .center
    stackView.addArrangedSubview(label)
  }

  private func addDivider() {
    let divider = UIView()
    divider.backgroundColor = .separator
    divider.translatesAutoresizingMaskIntoConstraints = false
    divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
    stackView.addArrangedSubview(divider)
    divider.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
  }

  private func makeButton(title: String, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.addTarget(self, action: action, for: .touchUpInside)
    button.titleLabel?.font = .systemFont(ofSize: 16)
    return button
  }

  private func showToast(_ message: String) {
    let toast = UILabel()
    toast.text = "  \(message)  "
    toast.textColor = .white
    toast.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    toast.textAlignment = .center
    toast.font = .systemFont(ofSize: 14)
    toast.layer.cornerRadius = 8
    toast.clipsToBounds = true
    toast.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toast)
    NSLayoutConstraint.activate([
      toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
    ])

    UIView.animate(withDuration: 0.3, delay: 1.0, options: .curveEaseOut, animations: {
      toast.alpha = 0
    }, completion: { _ in
      toast.removeFromSuperview()
    })
  }

  // MARK: - Actions

  @objc private func toggleUser() {
    if isUserRegistered {
      ShipBook.logout()
      isUserRegistered = false
      showToast("Sent: Logout")
    } else {
      ShipBook.registerUser(
        userId: "test\(userCounter)",
        userName: "testuser\(userCounter)",
        fullName: "Test User \(userCounter)",
        email: "test\(userCounter)@test.com",
        phoneNumber: "+1555000\(userCounter)",
        additionalInfo: ["role": "tester", "index": "\(userCounter)"]
      )
      isUserRegistered = true
      showToast("Sent: Register user [test\(userCounter)]")
      userCounter += 1
    }
    updateRegisterButtonTitle()
  }

  private func updateRegisterButtonTitle() {
    let title = isUserRegistered
      ? "Logout from Shipbook"
      : "Register user [test\(userCounter)]"
    registerButton.setTitle(title, for: .normal)
  }

  @objc private func setScreen() {
    ShipBook.screen(name: "Home")
    showToast("Sent: Set screen to Home")
  }

  @objc private func logError() {
    log.e("Test error message")
    showToast("Sent: Error")
  }

  @objc private func logWarning() {
    log.w("Test warning message")
    showToast("Sent: Warning")
  }

  @objc private func logInfo() {
    log.i("Test info message")
    showToast("Sent: Info")
  }

  @objc private func logDebug() {
    log.d("Test debug message")
    showToast("Sent: Debug")
  }

  @objc private func logVerbose() {
    log.v("Test verbose message")
    showToast("Sent: Verbose")
  }

  @objc private func logException() {
    let exception = NSException(
      name: .genericException,
      reason: "Test exception from example app",
      userInfo: nil
    )
    log.e("Caught exception: \(exception.name.rawValue) - \(exception.reason ?? "")")
    showToast("Sent: Log Exception")
  }

  @objc private func throwUncaughtException() {
    let numbers: [Int] = []
    let _ = numbers[0]
  }

  @objc private func flushLogs() {
    ShipBook.flush()
    showToast("Sent: Flush Logs")
  }

  @objc private func raceConditionTest() {
    let queue = DispatchQueue(label: "io.shipbook.raceConditionTest", attributes: .concurrent)
    for i in 1...1000 {
      queue.async {
        Log.i("Race condition log #\(i)")
      }
    }
    queue.async(flags: .barrier) {
      DispatchQueue.main.async { [weak self] in
        self?.showToast("Race condition test completed")
      }
    }
  }
}
