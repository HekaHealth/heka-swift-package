//
//  File.swift
//
//
//  Created by Pulkit Goyal on 02/02/23.
//

import Alamofire
import Foundation
import SwiftyJSON

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
        let id = data["id"] as! Int
        let userUuid = data["user_uuid"] as! String
        let connectedPlatformsArray = data["connected_platforms"] as! [[String: Any]]
        let connectedPlatforms = connectedPlatformsArray.map { platformData -> ConnectedPlatform in
          let platform = platformData["platform_name"] as! String
          let loggedIn = platformData["logged_in"] as! Bool
          let lastSync = platformData["last_sync"] as? String
          return ConnectedPlatform(platform: platform, loggedIn: loggedIn, lastSync: lastSync)
        }

        let connection = Connection(
          id: id, userUuid: userUuid, connectedPlatforms: connectedPlatforms)
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

    var components = URLComponents(string: "\(baseURL)/connect_platform_for_user")!
    components.queryItems = queryItems
    AF.request(
      components.url!,
      method: .post,
      parameters: [
        "key": apiKey,
        "user_uuid": userUuid,
        "refresh_token": googleFitRefreshToken,
        "email": emailId,
        "platform": platform,
      ],
      encoding: JSONEncoding.default
    )
    .responseJSON { response in
      switch response.result {
      case let .success(value):
        let json = JSON(value)
        if let data = json["data"].dictionary,
          let id = data["id"]?.int,
          let userUuid = data["user_uuid"]?.string,
          let connectedPlatforms = data["connected_platforms"]?.array
        {
          let connection = Connection(
            id: id,
            userUuid: userUuid,
            connectedPlatforms: connectedPlatforms.compactMap { platformJSON in
              guard let platformDict = platformJSON.dictionary,
                let platform = platformDict["platform"]?.string,
                let loggedIn = platformDict["logged_in"]?.bool,
                let lastSync = platformDict["last_sync"]?.string
              else {
                return nil
              }
              return ConnectedPlatform(
                platform: platform,
                loggedIn: loggedIn,
                lastSync: lastSync
              )
            }
          )
          completion(.success(connection))
        } else {
          // TODO: do something here
          // completion(.failure())
        }
      case let .failure(error):
        completion(.failure(error))
      }
    }

  }

}
