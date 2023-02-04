//
//  HekaComponent.swift
//  
//
//  Created by Gaurav Tiwari on 03/02/23.
//

import UIKit

final public class HekaComponent: UIView {

  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var btnConnection: UIButton!
  @IBOutlet private weak var lblSyncing: UILabel!
  
  var state: ConnectionState = .notConnected {
    didSet {
      DispatchQueue.main.async {
        self.configureSyncingLabel()
        self.configureButton()
      }
    }
  }
  
  var userUUID: String?
  var key: String?
  var apiManager: APIManager?
  let hekaManager = HekaManager()
  
  public override init(frame: CGRect) {
    super.init(frame: .zero)
    loadXIB()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  convenience public init(userUUID: String, key: String) {
    self.init(frame: .zero)
    self.userUUID = userUUID
    self.key = key
    apiManager = APIManager(apiKey: key)
    loadXIB()
    checkConnectionStatus()
    
  }
  
  public func setUser(uuid: String, and key: String) {
    self.userUUID = uuid
    self.key = key
    apiManager = APIManager(apiKey: key)
    loadXIB()
    checkConnectionStatus()
  }
  
  private func loadXIB() {
    let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
    guard let contentView = loadedNib?.first as? UIView else {
      fatalError("Unable to locate UI component")
    }
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
  
  //MARK: - Button action
  @IBAction private func actionConnectButton() {
    switch state {
      case .notConnected:
        DispatchQueue.main.async {
          self.checkHealthKitPermissions()
        }
      case .syncing, .connected:
        break
    }
  }
}

  //MARK: - Private Methods
private extension HekaComponent {
  func configureSyncingLabel() {
    lblSyncing.isHidden = state.isSyncingLabelHidden
  }
  
  func configureButton() {
    btnConnection.backgroundColor = state.buttonBGColor
    btnConnection.setTitle(state.buttonTitle, for: .normal)
  }
}
