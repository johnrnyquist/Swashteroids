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

typealias Layer = CGFloat

extension Layer {
    static let bottom: Layer = 1
    static let asteroids: Layer = 2
    static let powerUps: Layer = 2.1
    static let gameOver: Layer = 2.5
    static let torpedoes: Layer = 3
    static let player: Layer = 4
    static let buttons: Layer = 6
    static let hud: Layer = 7
    static let top: Layer = 8
}

extension CGFloat {
    var cgSize: CGSize {
        return CGSize(width: CGFloat(self), height: CGFloat(self))
    }
}
