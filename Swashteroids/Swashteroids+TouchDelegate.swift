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
    private var touchedComponents: [Int: TouchedComponent] = [:]
    let scene: SKScene

    init(scene: SKScene) {
        self.scene = scene
    }

    func began(_ touch: UITouch) {
        print("BEGAN")
        let location = touch.location(in: scene)
        let nodes = scene.nodes(at: location)
        guard !nodes.isEmpty else { return }
        if let topEntity = nodes
                .compactMap({ $0 as? SwashSpriteNode })
                .filter({ $0.entity?.has(componentClass: TouchableComponent.self) == true })
                .max(by: { $0.zPosition < $1.zPosition }) {
            touchCount += 1
            let component = TouchedComponent(id: touch.hash, num: touchCount, state: .began, locationInScene: location)
            topEntity.entity?.add(component: component)
            touchedComponents[touch.hash] = component
        }
    }

    func ended(_ touch: UITouch) {
        print("ENDED")
        touchedComponents[touch.hash]?.locationInScene = touch.location(in: scene)
        touchedComponents[touch.hash]?.state = .ended
    }

    func moved(_ touch: UITouch) {
        touchedComponents[touch.hash]?.locationInScene = touch.location(in: scene)
        touchedComponents[touch.hash]?.state = .moved
    }

    func remove(_ id: Int) {
        print("REMOVED")
        touchedComponents.removeValue(forKey: id)
    }
}

extension Swashteroids: TouchDelegate {
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchManager.began(touch)
        }
    }

    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchManager.ended(touch)
        }
    }

    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchManager.moved(touch)
        }
    }

    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            touchManager.ended(touch)
        }
    }
}
