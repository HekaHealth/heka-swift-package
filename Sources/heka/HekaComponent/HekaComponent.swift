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
  
  init(userUUID: String, key: String) {
    self.userUUID = userUUID
    self.key = key
    apiManager = APIManager(apiKey: key)
    super.init(frame: .zero)
  }
  
  public override init(frame: CGRect) {
    super.init(frame: .zero)
    loadXIB()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    loadXIB()
  }
  
  private func loadXIB() {
    let bundle = Bundle(for: HekaComponent.self)
    bundle.loadNibNamed(String(describing: self), owner: self)
    addSubview(contentView)
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
  }
  
  //MARK: - Button action
  @IBAction private func actionConnectButton() {
    switch state {
      case .notConnected:
        checkHealthKitPermissions()
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
