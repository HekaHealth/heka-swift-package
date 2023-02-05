//
//  ConnectionState.swift
//
//
//  Created by Gaurav Tiwari on 03/02/23.
//

import UIKit

enum ConnectionState {
  case notConnected, syncing, connected

  var buttonTitle: String {
    switch self {
    case .notConnected:
      return "Connect"
    case .syncing:
      return "Syncing"
    case .connected:
      return "Connected"
    }
  }

  var buttonBGColor: UIColor {
    switch self {
    case .notConnected:
      return UIColor(named: "connect") ?? .systemOrange
    case .syncing:
      return UIColor.lightGray
    case .connected:
      return UIColor.systemBlue
    }
  }

  var isSyncingLabelHidden: Bool {
    self != .syncing
  }
}
