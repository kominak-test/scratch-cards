//
//  ScratchingScreen.swift
//

import SwiftUI

struct ScratchingScreen: View {

    let viewModel: ScratchCardViewModel

    var body: some View {
        VStack {
            if viewModel.isScratchButtonVisible {
                Button("Scratch it!") {
                    Task {
                        await viewModel.scratchCard()
                    }
                }
                .bold()
            }
            if viewModel.isScratchingIndicatorVisible {
                Text("Scratching, please wait...")
                ProgressView()
            }
            if let text = viewModel.scratchedCardDescription {
                Text(text)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .navigationTitle("Scratch Card")
        .onDisappear {
            viewModel.cancelScratchingCard()
        }
    }
}

#Preview {
    NavigationStack {
        ScratchingScreen(viewModel: .init(state: .notScratched))
    }
}
