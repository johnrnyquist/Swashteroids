import Foundation
import Swash
import UIKit.UITouch

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
