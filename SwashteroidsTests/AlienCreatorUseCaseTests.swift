//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import XCTest
@testable import Swashteroids
@testable import Swash
import SpriteKit

final class AlienCreatorUseCaseTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    class MockAlertPresenting: AlertPresenting {
        var isAlertPresented: Bool

        init() { isAlertPresented = false }

        func showPauseAlert() {}

        func home() {}

        func resume() {}
    }

    func test_createAliens() throws {
        let engine = Engine()
        let creator = Creator(engine: engine,
                              size: .zero,
                              alertPresenter: MockAlertPresenting(),
                              randomness: Randomness(seed: 1))
        creator.createAliens(scene: GameScene(size: .zero))
        //TODO: Finish test
    }
}