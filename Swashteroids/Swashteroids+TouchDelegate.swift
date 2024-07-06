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
import Swash

protocol TouchDelegate: AnyObject {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

final class TouchManager {
    private var touchCount = 0
    private var touchedComponents: [UITouch: TouchedComponent] = [:]
    let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
    }

    func began(_ touch: UITouch) {
        touchCount += 1
        let location = touch.location(in: scene)
        let component = TouchedComponent(id: touch, num: touchCount, state: .began, locationInScene: location)
        touchedComponents[touch] = component
        print("BEGAN", touchedComponents[touch]?.num ?? -1)
        let nodes = scene.nodes(at: location)
        guard !nodes.isEmpty else { return }
        if let topEntity = nodes
                .compactMap({ $0 as? SwashSpriteNode })
                .filter({ $0.entity?.has(componentClass: TouchableComponent.self) == true })
                .filter({ $0.entity?.has(componentClass: TouchedComponent.self) == false })
                .max(by: { $0.zPosition < $1.zPosition }) {
            topEntity.entity?.add(component: component)
            print("ADDED", component.num, topEntity.name!)
        }
    }

    func ended(_ touch: UITouch) {
        print("ENDED", touchedComponents[touch]?.num ?? -1)
        touchedComponents[touch]?.locationInScene = touch.location(in: scene)
        touchedComponents[touch]?.state = .ended
    }

    func moved(_ touch: UITouch) {
        touchedComponents[touch]?.locationInScene = touch.location(in: scene)
        touchedComponents[touch]?.state = .moved
    }

    func remove(_ id: UITouch) {
        print("REMOVED", touchedComponents[id]?.num ?? -1)
        touchedComponents.removeValue(forKey: id)
    }
}

extension Swashteroids: TouchDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            manager_touch.began(touch)
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            manager_touch.ended(touch)
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            manager_touch.moved(touch)
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            manager_touch.ended(touch)
        }
    }
}
