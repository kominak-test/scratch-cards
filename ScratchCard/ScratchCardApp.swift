//
//  ScratchCardApp.swift
//

import SwiftUI

@main
struct ScratchCardApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreen(viewModel: ScratchCardViewModel())
        }
    }
}
