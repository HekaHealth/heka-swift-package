  //
  //  HekaComponent+Extension.swift
  //
  //
  //  Created by Gaurav Tiwari on 03/02/23.
  //

import UIKit

extension HekaComponent {
  
  func checkConnectionStatus() {
    guard let uuid = userUUID else {
      fatalError("user's UUID not set for the HekaComponent")
    }
    apiManager?.fetchConnection(user_uuid: uuid) { connection in
      guard let connection = connection else {
        print("Not Connected")
        return
      }
      
      self.state = .connected
      print(connection.connectedPlatforms)
    }
  }
  
  func checkHealthKitPermissions() {
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
  
  private func makeRequestToWatchSDK(){
    
      //TODO: - Setup observer query
    apiManager?.makeConnection(
      userUuid: userUUID!, platform: "apple_healthkit",
      googleFitRefreshToken: nil, emailId: nil
    ) { result in
      switch result {
        case .success(let connection):
          self.state = .connected
          print(connection.connectedPlatforms)
        case .failure(let failure):
          self.presentAlert(with: failure.localizedDescription)
      }
    }
  }
  
  private func presentAlert(with message: String) {
    let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    let keyWindow = UIApplication.shared.connectedScenes
      .filter({ $0.activationState == .foregroundActive })
      .compactMap({ $0 as? UIWindowScene })
      .first?.windows
      .filter({$0.isKeyWindow}).first
    
    DispatchQueue.main.async {
      keyWindow?.rootViewController?.present(alert, animated: true)
    }
  }
}
