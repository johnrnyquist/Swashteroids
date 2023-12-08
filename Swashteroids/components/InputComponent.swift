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

/// This class is a singleton, and is used to track the state of the input.
/// I made it a component to pass along to systems.
final class InputComponent: Component {
    static let instance = InputComponent()
    var leftIsDown: (down: Bool, amount: Double) = (false, 0.0)
    var rightIsDown: (down: Bool, amount: Double) = (false, 0.0)
    var thrustIsDown = false
    var touchDowns: [UITouch: Entity] = [:]

    func handleTouchDowns(nodes: [SKNode], touch: UITouch, location: CGPoint) {
        guard let originalEntity: Entity =
        nodes.compactMap({
            if let entity = ($0 as? SwashteroidsSpriteNode)?.entity,
               entity.has(componentClassName: TouchableComponent.name),
               let _ = entity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent {
                return entity
            } else {
                return nil
            }
        }).first
        else { return }
        if let sprite = originalEntity.sprite {
            (originalEntity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent)?.touchDown?(
                sprite)
        }
//        let touch = Touch(id: touch.hash, time: touch.timestamp, location: location, tapCount: touch.tapCount, phase: touch.phase, entity: originalEntity)
        touchDowns[touch] = originalEntity
    }

    func handleTouchUps(nodes: [SKNode], touch: UITouch, location: CGPoint) {
        guard let originalEntity = touchDowns[touch] else { return }
        let entity: Entity? =
            nodes.compactMap({
                if let entity = ($0 as? SwashteroidsSpriteNode)?.entity,
                   entity.has(componentClassName: TouchableComponent.name),
                   let _ = entity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent {
                    return entity
                } else {
                    return nil
                }
            }).first
        if let sprite = originalEntity.sprite {
            if entity == originalEntity {
                (originalEntity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent)?.touchUp?(
                    sprite)
            } else {
                (originalEntity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent)?.touchUpOutside?(
                    sprite)
            }
        }
        touchDowns[touch] = nil
    }

    func handleTouchMoveds(nodes: [SKNode], touch: UITouch, location: CGPoint) {
        guard let originalEntity = touchDowns[touch] else { return }
        let entity: Entity? =
            nodes.compactMap({
                     if let entity = ($0 as? SwashteroidsSpriteNode)?.entity,
                        entity.has(componentClassName: TouchableComponent.name) {
                         return entity
                     } else {
                         return nil
                     }
                 })
                 .first
        if let sprite = originalEntity.sprite {
            (originalEntity.get(componentClassName: ButtonBehaviorComponent.name) as? ButtonBehaviorComponent)?.touchMoved?(
                sprite,
                entity == originalEntity)
        }
    }
}
