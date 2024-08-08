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

extension Entity {
    var sprite: SwashSpriteNode? {
        let component = find(componentClass: DisplayComponent.self)
        return component?.sprite
    }
}

import SpriteKit

extension Entity {
    /// Flash the entity's sprite
    /// - Parameters:
    /// - numFlashes: The number of times to flash
    /// - duration: The duration the fadeIn/fadeOut
    /// - endAlpha: The final alpha value
    /// - wait: The time to wait between flashes
    @discardableResult
    func flash(_ numFlashes: Int = 1, duration: TimeInterval = 0.2, endAlpha: Double = 0.2, wait: TimeInterval = 0) -> Entity {
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration)
        let wait = SKAction.wait(forDuration: wait)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: duration)
        let flashes = Array(repeating: [fadeIn, fadeOut], count: numFlashes).flatMap { $0 }
        let flashSeq = SKAction.sequence(flashes)
        let seq = SKAction.sequence([flashSeq, wait, SKAction.fadeAlpha(to: CGFloat(endAlpha), duration: duration)])
        let sknode = self[DisplayComponent.self]?.sknode
        sknode?.run(seq)
        return self
    }
}
