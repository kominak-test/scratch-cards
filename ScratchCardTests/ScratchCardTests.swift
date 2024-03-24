//
//  ScratchCardTests.swift
//

import XCTest
@testable import ScratchCard

final class ScratchCardTests: XCTestCase {

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    @MainActor func testInitialHomeScreen() async throws {
        let viewModel = ScratchCardViewModel()

        XCTAssert(viewModel.isScratchLinkEnabled)
        XCTAssertFalse(viewModel.isActivateLinkEnabled)
    }

    @MainActor func testSuccessfulScratching() async throws {
        let viewModel = ScratchCardViewModel()

        XCTAssertEqual(viewModel.state, .notScratched)
        XCTAssert(viewModel.isScratchLinkEnabled)
        XCTAssertFalse(viewModel.isActivateLinkEnabled)
        XCTAssert(viewModel.isScratchButtonVisible)
        XCTAssertFalse(viewModel.isScratchingIndicatorVisible)
        XCTAssertNil(viewModel.scratchedCardDescription)

        await viewModel.scratchCard()

        guard case .scratched(id: let id) = viewModel.state else {
            XCTFail("Unexpected state after scratching")
            return
        }

        XCTAssertFalse(viewModel.isScratchLinkEnabled)
        XCTAssert(viewModel.isActivateLinkEnabled)
        XCTAssertFalse(viewModel.isScratchButtonVisible)
        XCTAssertFalse(viewModel.isScratchingIndicatorVisible)
        XCTAssertEqual(viewModel.scratchedCardDescription?.contains(id.uuidString), true)
    }

    @MainActor func testCancelledScratching() async throws {
        let viewModel = ScratchCardViewModel()

        XCTAssertEqual(viewModel.state, .notScratched)

        XCTAssert(viewModel.isScratchLinkEnabled)
        XCTAssertFalse(viewModel.isActivateLinkEnabled)
        XCTAssert(viewModel.isScratchButtonVisible)
        XCTAssertFalse(viewModel.isScratchingIndicatorVisible)
        XCTAssertNil(viewModel.scratchedCardDescription)

        Task {
            await viewModel.scratchCard()
        }
        viewModel.cancelScratchingCard()

        XCTAssertEqual(viewModel.state, .notScratched)

        XCTAssert(viewModel.isScratchLinkEnabled)
        XCTAssertFalse(viewModel.isActivateLinkEnabled)
        XCTAssert(viewModel.isScratchButtonVisible)
        XCTAssertFalse(viewModel.isScratchingIndicatorVisible)
        XCTAssertNil(viewModel.scratchedCardDescription)
    }

    @MainActor func testActivationUrl() async throws {
        let id = UUID()
        let viewModel = ScratchCardViewModel(state: .scratched(id: id))

        XCTAssertEqual(viewModel.activationUrl, URL(string: "https://api.o2.sk/version?code=\(id.uuidString)"))
    }

    @MainActor func testSuccessfulActivating() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]

        let session = URLSession(configuration: config)

        let id = UUID()

        let viewModel = ScratchCardViewModel(state: .scratched(id: id), urlSession: session)

        URLProtocolMock.dataForURLs[viewModel.activationUrl] = "{ \"ios\": \"6.2\" }".data(using: .utf8)

        XCTAssertFalse(viewModel.isScratchLinkEnabled)
        XCTAssert(viewModel.isActivateLinkEnabled)
        XCTAssert(viewModel.isActivateButtonVisible)
        XCTAssertFalse(viewModel.isActivatingIndicatorVisible)
        XCTAssertFalse(viewModel.isActivatedMessageVisible)
        XCTAssertFalse(viewModel.isActivationErrorMessageVisible)

        await viewModel.activateCard()

        XCTAssertEqual(viewModel.state, .activated(id: id))

        XCTAssertFalse(viewModel.isScratchLinkEnabled)
        XCTAssertFalse(viewModel.isActivateLinkEnabled)
        XCTAssertFalse(viewModel.isActivateButtonVisible)
        XCTAssertFalse(viewModel.isActivatingIndicatorVisible)
        XCTAssert(viewModel.isActivatedMessageVisible)
        XCTAssertFalse(viewModel.isActivationErrorMessageVisible)
    }

    @MainActor func testUnsuccessfulActivating() async throws {
        let invalidResponses = [
            "{ \"ios\": \"6.1\" }",
            "{ \"invalid_ios_key\": \"6.2\" }",
            "invalid JSON...",
        ]

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]

        let session = URLSession(configuration: config)

        for invalidResponse in invalidResponses {
            let id = UUID()

            let viewModel = ScratchCardViewModel(state: .scratched(id: id), urlSession: session)

            URLProtocolMock.dataForURLs[viewModel.activationUrl] = invalidResponse.data(using: .utf8)

            XCTAssertFalse(viewModel.isScratchLinkEnabled)
            XCTAssert(viewModel.isActivateLinkEnabled)
            XCTAssert(viewModel.isActivateButtonVisible)
            XCTAssertFalse(viewModel.isActivatingIndicatorVisible)
            XCTAssertFalse(viewModel.isActivatedMessageVisible)
            XCTAssertFalse(viewModel.isActivationErrorMessageVisible)

            await viewModel.activateCard()

            XCTAssertEqual(viewModel.state, .scratched(id: id))

            XCTAssertFalse(viewModel.isScratchLinkEnabled)
            XCTAssert(viewModel.isActivateLinkEnabled)
            XCTAssert(viewModel.isActivateButtonVisible)
            XCTAssertFalse(viewModel.isActivatingIndicatorVisible)
            XCTAssertFalse(viewModel.isActivatedMessageVisible)
            XCTAssert(viewModel.isActivationErrorMessageVisible)
        }
    }
}
