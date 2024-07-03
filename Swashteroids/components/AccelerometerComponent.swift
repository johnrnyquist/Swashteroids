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
import SpriteKit

/// This class is used to track the state of the buttons input.
/// It breaks the rules of Swash by having logic in a component as the ButtonBehaviorComponent has actions.
/// I made it a component to pass along to systems.
final class AccelerometerComponent: Component {
    static let shared = AccelerometerComponent()

    private override init() {}

//    private var touchDowns: [UITouch: Entity] = [:]
    //
    // Used to capture the accelerometer data and up/down state.
    // I'm using a tuple instead of an enum with an associated value for simplicity.
    var rotate: (isDown: Bool, amount: Double) = (false, 0.0)

    /// We're only interested in touches on SwashSpriteNodes
    /// that have an entity which has a TouchableComponent.
//    func handleTouchDowns(nodes: [SKNode], touch: UITouch, location: CGPoint) {
//        guard let originalEntity: Entity =
//        nodes.compactMap({
//            if let entity = ($0 as? SwashSpriteNode)?.entity,
//               entity.has(componentClassName: TouchableComponent.name),
//               let _ = entity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent {
//                return entity
//            } else {
//                return nil
//            }
//        }).first
//        else { return }
//        if let sprite = originalEntity.sprite {
//            (originalEntity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent)?.touchDown?(
//                sprite)
//        }
////        let touch = Touch(id: touch.hash, time: touch.timestamp, location: location, tapCount: touch.tapCount, phase: touch.phase, entity: originalEntity)
//        touchDowns[touch] = originalEntity
//    }

//    func handleTouchUps(nodes: [SKNode], touch: UITouch, location: CGPoint) {
//        guard let originalEntity = touchDowns[touch] else { return }
//        let entity: Entity? =
//            nodes.compactMap({
//                if let entity = ($0 as? SwashSpriteNode)?.entity,
//                   entity.has(componentClassName: TouchableComponent.name),
//                   let _ = entity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent {
//                    return entity
//                } else {
//                    return nil
//                }
//            }).first
//        if let sprite = originalEntity.sprite {
//            if entity == originalEntity {
//                (originalEntity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent)?.touchUp?(sprite)
//            } else {
//                (originalEntity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent)?.touchUpOutside?(sprite)
//            }
//        }
//        touchDowns[touch] = nil
//    }

//    func handleTouchMoveds(nodes: [SKNode], touch: UITouch, location: CGPoint) {
//        guard let originalEntity = touchDowns[touch] else { return }
//        let entity: Entity? =
//            nodes.compactMap({
//                     if let entity = ($0 as? SwashSpriteNode)?.entity,
//                        entity.has(componentClassName: TouchableComponent.name) {
//                         return entity
//                     } else {
//                         return nil
//                     }
//                 })
//                 .first
//        if let sprite = originalEntity.sprite {
//            (originalEntity[ButtonBehaviorComponent.name] as? ButtonBehaviorComponent)?.touchMoved?(sprite,
//                                                                                                    entity == originalEntity)
//        }
//    }
}
