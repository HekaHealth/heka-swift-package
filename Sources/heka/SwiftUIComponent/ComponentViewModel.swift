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
      errorOccured = true
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
  func checkConnectionStatus() {
    apiManager.fetchConnection(user_uuid: uuid) { connection in
      guard connection != nil else {
        self.state = .notConnected
        return
      }
      self.state = .connected
    }
  }
  
  {
    guard hekaManager.checkHealthKitPermissions() else {
      hekaManager.requestAuthorization { allowed in
        if allowed {
          self.makeRequestToWatchSDK()
        } else {
          self.presentAlert(with: "Allow health data permissions in the Seetings App")
        }
      }
      return
    }
    
    hekaManager.syncIosHealthData(
      apiKey: key!, userUuid: userUUID!,
      completion: { success in
        if success {
        } else {
          self.presentAlert(with: "Unable to sync health data")
        }
      })
    
    makeRequestToWatchSDK()
  }
  
  func checkHealthKitPermissions() {
    guard hekaManager.checkHealthKitPermissions() else {
      hekaManager.requestAuthorization { allowed in
        if allowed {
          self.makeRequestToWatchSDK()
        } else {
          self.errorDescription = "Please allow health app access permission, in order to use this widget"
        }
      }
      return
    }
    
    state = .syncing
    
    hekaManager.syncIosHealthData(
      apiKey: apiKey, userUuid: uuid
    ) { success in
      if success {
        self.state = .connected
      } else {
        self.state = .notConnected
        self.errorDescription = "Unable to sync health data"
      }
    }
    
    makeRequestToWatchSDK()
  }
  
  private func makeRequestToWatchSDK() {
    apiManager.makeConnection(
      userUuid: uuid, platform: "apple_healthkit",
      googleFitRefreshToken: nil, emailId: nil
    ) { result in
      switch result {
        case .success:
          self.state = .connected
        case .failure(let failure):
          self.state = .notConnected
          self.errorDescription = failure.localizedDescription
      }
    }
  }
}
