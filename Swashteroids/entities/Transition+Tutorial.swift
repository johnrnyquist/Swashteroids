//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import Foundation.NSDate
import SpriteKit
import SwiftySound

class TutorialTransition: TutorialUseCase {
    private let engine: Engine

    init(engine: Engine) {
        self.engine = engine
    }

    func fromTutorialScreen() {
    }

    func toTutorialScreen() {
        let tutorial = Entity(named: .tutorial)
                .add(component: TutorialComponent())
        engine.add(entity: tutorial)
    }
}
