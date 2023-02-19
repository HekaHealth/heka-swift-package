//
//  ConnectionEndpoint.swift
//  
//
//  Created by Gaurav Tiwari on 19/02/23.
//

import Alamofire
import UIKit

enum ConnectionEndpoint: Endpoint {
  
  case fetch(apiKey: String, userUUID: String)
  case connect(apiKey: String, userUUID: String, googleFitRefreshToken: String?, emailID: String?, platform: String)
  case disconnect (apiKey: String, userUUID: String, platform: String)
  
  var url: String {
    switch self {
      case .fetch:
        return "\(base)/check_watch_connection"
      case let .connect(apiKey: apiKey, userUUID: userUUID, _, _, _):
        let queryItems = [
          URLQueryItem(name: "key", value: apiKey),
          URLQueryItem(name: "user_uuid", value: userUUID)
        ]
        var components = URLComponents(string: "\(base)/connect_platform_for_user")!
        components.queryItems = queryItems
        return components.url!.absoluteString
      case let .disconnect(apiKey: apiKey, userUUID: userUUID, _):
        let queryItems = [
          URLQueryItem(name: "key", value: apiKey),
          URLQueryItem(name: "user_uuid", value: userUUID),
          URLQueryItem(name: "disconnect", value: String(true))
        ]
        var components = URLComponents(string: "\(base)/connect_platform_for_user")!
        components.queryItems = queryItems
        return components.url!.absoluteString
    }
  }
  
  var method: Alamofire.HTTPMethod {
    switch self {
      case .fetch:
        return .get
      case .connect, .disconnect:
        return .post
    }
  }
  
  var parameters: Alamofire.Parameters? {
    switch self {
      case .fetch(let apiKey, let userUUID):
        return ["key": apiKey, "user_uuid": userUUID]
      case let .connect(_, _, googleFitRefreshToken: refreshToken, emailID: email, platform: platformIdentifier):
        var parameters = [
          "platform": platformIdentifier,
          "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
        
        if let email = email {
          parameters["email"] = email
        }
        if let refreshToken = refreshToken {
          parameters["refresh_token"] = refreshToken
        }
        
        return parameters
      case .disconnect(_, _, platform: let platformIdentifier):
        return [
          "platform": platformIdentifier,
          "device_id": UIDevice.current.identifierForVendor!.uuidString
        ]
    }
  }
  
  var encoding: ParameterEncoding {
    switch self {
      case .fetch:
        return URLEncoding.default
      case .connect, .disconnect:
        return JSONEncoding.default
    }
  }
}
