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
  private let hekaManager = HekaManager()
  private let connectionClient: ConnectionClient

  init(uuid: String, apiKey: String) {
    self.uuid = uuid
    self.apiKey = apiKey
    connectionClient = ConnectionClient(apiKey: apiKey, userUUID: uuid, platform: "apple_healthkit")
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
    connectionClient.fetchConnection { result in
      switch result {
        case .failure(let error):
          self.errorDescription = error.localizedDescription
          self.setState(to: .notConnected)
        case .success(let connection):
          if connection.isPlatformConnected(platform: "apple_healthkit") {
            self.setState(to: .connected)
          } else {
            self.setState(to: .notConnected)
          }
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

  func disconnectFromServer() {
    connectionClient.disconnect { result in
      switch result {
        case .failure(let error):
          self.errorDescription = error.localizedDescription
        case .success:
          self.setState(to: .notConnected)
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
    
    connectionClient.connectToServer { result in
      switch result {
        case .success:
          self.syncIosHealthData()
        case .failure(let error):
          self.setState(to: .notConnected)
          self.errorDescription = error.localizedDescription
      }
    }
  }
}
