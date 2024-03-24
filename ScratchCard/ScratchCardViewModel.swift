//
//  ScratchCardViewModel.swift
//

import Foundation
import Observation

@Observable @MainActor
class ScratchCardViewModel {

    // MARK: - Data Model

    enum State: Equatable {
        case notScratched
        case scratching
        case scratched(id: UUID)
        case activating(id: UUID)
        case activated(id: UUID)
    }

    private(set) var state: State = .notScratched
    private let urlSession: URLSession
    private var scratchingTask: Task<Void, Error>?

    init(state: State = .notScratched, urlSession: URLSession = .shared) {
        self.state = state
        self.urlSession = urlSession
    }

    // MARK: - Home Screen

    var cardStateDescription: String {
        switch state {
        case .notScratched, .scratching: String(localized: "You have a card ready to be scratched.")
        case .scratched, .activating: String(localized: "Your card is scratched and ready to be activated.")
        case .activated: String(localized: "Your card is scratched and activated. Enjoy!")
        }
    }
    var isScratchLinkEnabled: Bool { state == .notScratched }
    var isActivateLinkEnabled: Bool { if case .scratched = state { true } else { false } }
    var isActivationErrorMessageVisible = false

    // MARK: - Scratch Screen

    var isScratchButtonVisible: Bool { state == .notScratched }
    var isScratchingIndicatorVisible: Bool { state == .scratching }
    var scratchedCardDescription: String? {
        switch state {
        case .scratched(id: let id): String(localized: "Your Card's Code:") + "\n" + id.uuidString
        case .notScratched, .scratching, .activated, .activating: nil
        }
    }

    func scratchCard() async {
        guard case .notScratched = state else { return }

        state = .scratching

        scratchingTask = Task(priority: .userInitiated) {
            do {
                // This method checks for cancellation internally and throws if cancelled
                try await Task.sleep(for: .seconds(2))

                await MainActor.run {
                    self.state = .scratched(id: .init())
                }
            }
            catch {
                await MainActor.run {
                    self.state = .notScratched
                }
            }
        }

        try? await scratchingTask?.value
    }

    func cancelScratchingCard() {
        scratchingTask?.cancel()
    }

    // MARK: - Activate Screen

    var isActivateButtonVisible: Bool { if case .scratched = state { true } else { false } }
    var isActivatingIndicatorVisible: Bool { if case .activating = state { true } else { false } }
    var isActivatedMessageVisible: Bool { if case .activated = state { true } else { false } }

    private struct VersionResponse: Codable {
        let ios: String

        var isValid: Bool {
            if let decimalValue = Decimal(string: ios),
                decimalValue > 6.1
            {
                true
            }
            else {
                false
            }
        }
    }

    func activateCard() async {
        guard case .scratched(let id) = state, 
            let url = activationUrl else
        {
            isActivationErrorMessageVisible = true
            return
        }

        state = .activating(id: id)

        defer {
            // If failed to activate: fall back to .scratched state
            if case .activating(let id) = state {
                state = .scratched(id: id)
            }
        }

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            let (data, _) = try await urlSession.data(for: request)
            let response = try JSONDecoder().decode(VersionResponse.self, from: data)

            if response.isValid {
                state = .activated(id: id)
            }
            else {
                isActivationErrorMessageVisible = true
            }
        }
        catch {
            isActivationErrorMessageVisible = true
        }
    }

    var activationUrl: URL? {
        if case .scratched(let id) = state,
           var urlComponents = URLComponents(string: "https://api.o2.sk/version")
        {
            urlComponents.queryItems = [
                URLQueryItem(name: "code", value: id.uuidString)
            ]

            return urlComponents.url
        }

        return nil
    }
}
