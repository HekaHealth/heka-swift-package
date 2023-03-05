//
//  Component.swift
//
//
//  Created by Gaurav Tiwari on 04/02/23.
//

import SwiftUI

public struct HekaUIView: View {

  @ObservedObject var viewModel: ComponentViewModel

  public init(uuid: String, apiKey: String) {
    viewModel = ComponentViewModel(uuid: uuid, apiKey: apiKey)
  }

  public var body: some View {
    HStack {
      Image("healthIcon", bundle: HekaResources.resourceBundle)
        .resizable()
        .frame(width: 50, height: 50)
        .padding()

      VStack(alignment: .leading) {
        Text("Apple HealthKit")
          .font(.headline)
        if viewModel.isSyncStatusLabelHidden == false {
          Text("Syncing data...")
            .font(.system(size: 12))
            .foregroundColor(.gray)
        }
      }

      Spacer()

      Button(viewModel.buttonTitle) {
        switch viewModel.currentConnectionState {
        case .notConnected:
          viewModel.checkHealthKitPermissions()
          break
        case .syncing:
          break
        case .connected:
          //TODO: - Maybe add some sort of confirmation
          viewModel.disconnectFromServer()
        }
      }
      .frame(width: 100, height: 40)
      .background(Color(viewModel.buttonBGColor))
      .foregroundColor(.white)
      .cornerRadius(20)
    }
    .padding(8)
    .cornerRadius(8)
    .compositingGroup()
    .background(Color(.white))
    .shadow(radius: 4)
    .onAppear {
      viewModel.checkConnectionStatus()
    }

    //TODO: - Work on Alert
    //        .alert(isPresented: $viewModel.errorOccured) {
    //            Alert(
    //                title: Text("Error!"),
    //                message: Text(viewModel.errorDescription),
    //                dismissButton: .default(Text("OK")) {
    //                    viewModel.errorOccured = false
    //                }
    //            )
    //        }
  }
}
