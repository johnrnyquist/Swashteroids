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
import Swash
import UIKit.UITouch

/// This is not currently in use. It's intent is for use with the InputComponent.
struct Touch: Identifiable, Equatable, Hashable {
    let id: Int
    let time: TimeInterval
    let location: CGPoint
    let tapCount: Int
    let phase: UITouch.Phase
    weak var entity: Entity? = nil
//    var entityName: EntityName? = nil

    static func ==(lhs: Touch, rhs: Touch) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
