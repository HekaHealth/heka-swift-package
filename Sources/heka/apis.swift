//
//  File.swift
//
//
//  Created by Pulkit Goyal on 02/02/23.
//

import Alamofire
import Foundation
import UIKit

class APIManager {

  let baseURL: String
  let apiKey: String

  init(apiKey: String) {
    self.baseURL = "https://apidev.hekahealth.co/watch_sdk"
    self.apiKey = apiKey
  }

  func fetchConnection(user_uuid: String, completion: @escaping (Connection?) -> Void) {

    AF.request(
      "\(baseURL)/check_watch_connection",
      method: .get,
      parameters: [
        "key": apiKey,
        "user_uuid": user_uuid,
      ]
    ).responseJSON { result in
      if let response = result.response, response.statusCode == 404 {
        completion(nil)
        return
      }
      guard let data = result.data, result.error == nil else {
        completion(nil)
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let data = json["data"] as! [String: Any]
        let userUuid = data["user_uuid"] as! String

        guard let connections = data["connections"] as? [String: [String: Any]?] else {
          // Handle error if the "connections" key is not found in the response
          return
        }
        var connectedPlatforms = [String: ConnectedPlatform]()
        for (platformName, platformData) in connections {
          if platformData == nil {
            connectedPlatforms[platformName] = nil
            continue
          }
          let platformData = platformData!
          let platform = platformData["platform_name"] as? String ?? ""
          let loggedIn = platformData["logged_in"] as? Bool ?? false
          let lastSync = platformData["last_sync"] as? String
          let connectedDeviceUUIDs = platformData["connected_device_uuids"] as? [String]

          let connectedPlatform = ConnectedPlatform(
            platform: platform, loggedIn: loggedIn, lastSync: lastSync,
            connectedDeviceUUIDs: connectedDeviceUUIDs)
          connectedPlatforms[platformName] = connectedPlatform
        }

        let connection = Connection(userUuid: userUuid, connectedPlatforms: connectedPlatforms)
        completion(connection)
      } catch {
        print("Error parsing JSON data: \(error)")
        completion(nil)
      }
    }
  }

  func makeConnection(
    userUuid: String, platform: String, googleFitRefreshToken: String?, emailId: String?,
    completion: @escaping (Result<Connection, Error>) -> Void
  ) {

    let queryItems = [
      URLQueryItem(name: "key", value: apiKey),
      URLQueryItem(name: "user_uuid", value: userUuid),
    ]

    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    var components = URLComponents(string: "\(baseURL)/connect_platform_for_user")!
    components.queryItems = queryItems
    AF.request(
      components.url!,
      method: .post,
      parameters: [
        "refresh_token": googleFitRefreshToken,
        "email": emailId,
        "platform": platform,
        "device_id": deviceId,
      ],
      encoding: JSONEncoding.default
    )
    .responseJSON { result in
      if let response = result.response, response.statusCode == 404 {
        // TODO: improve this error handling
        completion(
          .failure(NSError(domain: "com.heka", code: 404, userInfo: nil)))
        return
      }
      guard let data = result.data, result.error == nil else {
        completion(
          .failure(NSError(domain: "com.heka", code: 404, userInfo: nil)))
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let data = json["data"] as! [String: Any]
        let userUuid = data["user_uuid"] as! String

        guard let connections = data["connections"] as? [String: [String: Any]?] else {
          // Handle error if the "connections" key is not found in the response
          return
        }
        var connectedPlatforms = [String: ConnectedPlatform]()
        for (platformName, platformData) in connections {
          if platformData == nil {
            connectedPlatforms[platformName] = nil
            continue
          }
          let platformData = platformData!
          let platform = platformData["platform_name"] as? String ?? ""
          let loggedIn = platformData["logged_in"] as? Bool ?? false
          let lastSync = platformData["last_sync"] as? String
          let connectedDeviceUUIDs = platformData["connected_device_uuids"] as? [String]

          let connectedPlatform = ConnectedPlatform(
            platform: platform, loggedIn: loggedIn, lastSync: lastSync,
            connectedDeviceUUIDs: connectedDeviceUUIDs)
          connectedPlatforms[platformName] = connectedPlatform
        }

        let connection = Connection(userUuid: userUuid, connectedPlatforms: connectedPlatforms)
        completion(.success(connection))
      } catch {
        print("Error parsing JSON data: \(error)")
        completion(.failure(error))
      }
    }

  }

  func disconnect(
    userUuid: String, platform: String,
    completion: @escaping (Result<Connection, Error>) -> Void
  ) {
    let queryItems = [
      URLQueryItem(name: "key", value: apiKey),
      URLQueryItem(name: "user_uuid", value: userUuid),
      URLQueryItem(name: "disconnect", value: String(true)),
    ]

    let deviceId = UIDevice.current.identifierForVendor!.uuidString
    var components = URLComponents(string: "\(baseURL)/connect_platform_for_user")!
    components.queryItems = queryItems
    AF.request(
      components.url!,
      method: .post,
      parameters: [
        "platform": platform,
        "device_id": deviceId,
      ],
      encoding: JSONEncoding.default
    )
    .responseJSON { result in
      if let response = result.response, response.statusCode == 404 {
        completion(
          .failure(NSError(domain: "com.heka", code: 404, userInfo: nil)))
        return
      }
      guard let data = result.data, result.error == nil else {
        completion(
          .failure(NSError(domain: "com.heka", code: 404, userInfo: nil)))
        return
      }

      do {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        let data = json["data"] as! [String: Any]
        let userUuid = data["user_uuid"] as! String

        guard let connections = data["connections"] as? [String: [String: Any]?] else {
          // Handle error if the "connections" key is not found in the response
          return
        }
        var connectedPlatforms = [String: ConnectedPlatform]()
        for (platformName, platformData) in connections {
          if platformData == nil {
            connectedPlatforms[platformName] = nil
            continue
          }
          let platformData = platformData!
          let platform = platformData["platform_name"] as? String ?? ""
          let loggedIn = platformData["logged_in"] as? Bool ?? false
          let lastSync = platformData["last_sync"] as? String
          let connectedDeviceUUIDs = platformData["connected_device_uuids"] as? [String]

          let connectedPlatform = ConnectedPlatform(
            platform: platform, loggedIn: loggedIn, lastSync: lastSync,
            connectedDeviceUUIDs: connectedDeviceUUIDs)
          connectedPlatforms[platformName] = connectedPlatform
        }

        let connection = Connection(userUuid: userUuid, connectedPlatforms: connectedPlatforms)
        completion(.success(connection))
      } catch {
        print("Error parsing JSON data: \(error)")
        completion(.failure(error))
      }
    }

  }
}
