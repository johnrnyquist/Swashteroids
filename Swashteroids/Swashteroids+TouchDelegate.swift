//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SpriteKit

protocol TouchDelegate: AnyObject {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

//extension Swashteroids: TouchDelegate {
//    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: scene)
//            inputComponent.handleTouchDowns(nodes: scene.nodes(at: location), touch: touch, location: location)
//        }
//    }
//
//    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: scene)
//            inputComponent.handleTouchUps(nodes: scene.nodes(at: location), touch: touch, location: location)
//        }
//    }
//
//    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: scene)
//            let p = touch.location(in: scene) - touch.previousLocation(in: scene)
//            let d = max(abs(p.x), abs(p.y))
//            guard d > 1 else { return }
//            inputComponent.handleTouchMoveds(nodes: scene.nodes(at: location), touch: touch, location: location)
//        }
//    }
//
//    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            let location = touch.location(in: scene)
//            inputComponent.handleTouchUps(nodes: scene.nodes(at: location), touch: touch, location: location)
//        }
//    }
//}
import Swash

var touchedComponents: [UITouch: TouchedComponent] = [:] //HACK
extension Swashteroids: TouchDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            let location = touch.location(in: scene)
            scene.nodes(at: location)
                .compactMap { $0 as? SwashSpriteNode }
                .compactMap { $0.entity }
                .filter { $0.has(componentClassName: TouchableComponent.name) }
                .forEach { entity in
                    let component = TouchedComponent(touch: touch, state: .began)
                    entity.add(component: component)
                    touchedComponents[touch] = component
                }
        }
    }
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchedComponents[touch]?.state = .ended
            touchedComponents.removeValue(forKey: touch)
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchedComponents[touch]?.state = .moved
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchedComponents[touch]?.state = .cancelled
            touchedComponents.removeValue(forKey: touch)
        }
    }
}
