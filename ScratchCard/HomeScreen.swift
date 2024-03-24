//
//  HomeScreen.swift
//

import SwiftUI

struct HomeScreen: View {

    @Bindable var viewModel: ScratchCardViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text(viewModel.cardStateDescription)
                    .multilineTextAlignment(.center)

                NavigationLink {
                    ScratchingScreen(viewModel: viewModel)
                } label: {
                    Text("Scratch Card")
                        .padding()
                        .foregroundStyle(.white)
                        .background(Capsule())
                }
                .disabled(!viewModel.isScratchLinkEnabled)

                NavigationLink {
                    ActivatingScreen(viewModel: viewModel)
                } label: {
                    Text("Activate Card")
                        .padding()
                        .foregroundStyle(.white)
                        .background(Capsule())
                }
                .disabled(!viewModel.isActivateLinkEnabled)
            }
            .padding()
            .navigationTitle("My Scratch Cards")
        }
        .alert("Error occurred while activating the code", isPresented: $viewModel.isActivationErrorMessageVisible) { }
    }
}

#Preview {
    HomeScreen(viewModel: ScratchCardViewModel())
}
