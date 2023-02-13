//
//  ComponentViewModel.swift
//
//
//  Created by Gaurav Tiwari on 04/02/23.
//

import Combine
import UIKit

final class ComponentViewModel: ObservableObject {

  @Published private var state = ConnectionState.notConnected
  @Published var errorOccured = Bool()
  private(set) var errorDescription = String() {
    didSet {
      DispatchQueue.main.async {
        self.errorOccured = true
      }
    }
  }

  var uuid: String
  var apiKey: String
  private let apiManager: APIManager
  private let hekaManager = HekaManager()

  init(uuid: String, apiKey: String) {
    self.uuid = uuid
    self.apiKey = apiKey
    apiManager = APIManager(apiKey: apiKey)
  }

  var buttonTitle: String {
    state.buttonTitle
  }

  var isSyncStatusLabelHidden: Bool {
    state.isSyncingLabelHidden
  }

  var currentConnectionState: ConnectionState {
    state
  }

  var buttonBGColor: UIColor {
    state.buttonBGColor
  }
}

extension ComponentViewModel {
  private func setState(to newState: ConnectionState) {
    DispatchQueue.main.async {
      self.state = newState
    }
  }

  func checkConnectionStatus() {
    apiManager.fetchConnection(user_uuid: uuid) { connection in
      guard connection != nil else {
        self.setState(to: .notConnected)
        return
      }
      if connection?.isPlatformConnected(platform: "apple_healthkit") ?? false {
        self.setState(to: .connected)
      } else {
        self.setState(to: .notConnected)
      }
    }
  }

  func checkHealthKitPermissions() {
    hekaManager.requestAuthorization { allowed in
      if allowed {
        self.makeConnectionRequest()
      } else {
        self.errorDescription =
          "Please allow health app access permission, in order to use this widget"
      }
    }
  }

  private func syncIosHealthData() {
    self.hekaManager.syncIosHealthData(
      apiKey: self.apiKey, userUuid: self.uuid
    ) { success in
      if success {
        self.setState(to: .connected)
      } else {
        self.setState(to: .notConnected)
        self.errorDescription = "Unable to sync health data"
      }
    }
  }

  private func makeConnectionRequest() {
    self.setState(to: .syncing)
    apiManager.makeConnection(
      userUuid: uuid, platform: "apple_healthkit",
      googleFitRefreshToken: nil, emailId: nil
    ) { result in
      switch result {
      case .success:
        self.syncIosHealthData()
      case .failure(let failure):
        self.setState(to: .notConnected)
        self.errorDescription = failure.localizedDescription
      }
    }
  }
}
