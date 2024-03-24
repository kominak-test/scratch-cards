//
//  ActivatingScreen.swift
//

import SwiftUI

struct ActivatingScreen: View {

    let viewModel: ScratchCardViewModel

    var body: some View {
        VStack {
            if viewModel.isActivateButtonVisible {
                Button("Activate It!") {
                    Task {
                        await viewModel.activateCard()
                    }
                }
                .bold()
            }
            if viewModel.isActivatingIndicatorVisible {
                Text("Activating, please wait...")
                ProgressView()
            }
            if viewModel.isActivatedMessageVisible {
                Text("Activated Successfully")
                    .font(.headline)
            }
        }
        .padding()
        .navigationTitle("Activate Card")
    }
}

#Preview {
    NavigationStack {
        ActivatingScreen(viewModel: .init(state: .scratched(id: .init())))
    }
}
