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
      // Image("appleHealthKit", bundle: .module)
      //   .resizable()
      //   .frame(width: 25, height: 25)
      //   .padding()

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
    .background(Color(UIColor.secondarySystemBackground))
    .cornerRadius(8)
    .compositingGroup()
    .shadow(radius: 8)
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

struct HekaUIView_Previews: PreviewProvider {
  static var previews: some View {
    HekaUIView(
      uuid: UUID().uuidString,
      apiKey: "7368bad8-aadd-4624-a58c-7e8af2b3cfb7"
    )
  }
}
