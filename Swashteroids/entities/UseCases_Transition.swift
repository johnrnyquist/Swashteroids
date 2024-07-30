//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation

protocol GameOverUseCase: AnyObject {
    func fromGameOverScreen()
    func toGameOverScreen()
}

protocol InfoViewsUseCase: AnyObject {
    func fromAccelerometerInfoScreen()
    func toAccelerometerInfoScreen()
    func fromButtonsInfoScreen()
    func toButtonsInfoScreen()
}

protocol PlayingUseCase: AnyObject {
    func fromPlayingScreen()
    func toPlayingScreen(appStateComponent: GameStateComponent)
}

protocol StartUseCase: AnyObject {
    func fromStartScreen()
    func toStartScreen()
}

protocol TutorialUseCase: AnyObject {
    func fromTutorialScreen()
    func toTutorialScreen()
}