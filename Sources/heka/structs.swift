//
//  File.swift
//
//
//  Created by Pulkit Goyal on 02/02/23.
//

import Foundation

struct ConnectedPlatform {
  let platform: String
  let loggedIn: Bool
  let lastSync: String?
}

struct Connection {
  let id: Int
  let userUuid: String
  let connectedPlatforms: [ConnectedPlatform]

  func isPlatformConnected(platform: String) -> Bool {
    for connectedPlatform in connectedPlatforms {
      if connectedPlatform.platform == platform {
        return true
      }
    }
    return false
  }
}
