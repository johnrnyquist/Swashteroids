//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swashteroids

class MockAlertPresenter: AlertPresenting {
    func showSettings() {}
    
    func hideSettings() {}
    
    var isAlertPresented: Bool = false

    func home() {}

    func resume() {}

    func showPauseAlert() {}
}
