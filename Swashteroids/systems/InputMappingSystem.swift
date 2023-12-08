import Foundation
import Swash

/// Maps touch input to touchable entities
final class InputMappingSystem: ListIteratingSystem {
    private weak var touchables: NodeList!

    init() {
        super.init(nodeClass: InputNode.self)
        nodeUpdateFunction = updateNode
    }

    override public func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        touchables = engine.getNodeList(nodeClassType: TouchableNode.self)
    }

    func updateNode(node: Node, time: TimeInterval) {
//        guard let input = node[InputComponent.self] else { return }
//        handleTouchDowns(inputComponent: input)
//        handleTouchUps(inputComponent: input)
//        handleTouchMoveds(inputComponent: input)
    }
//
//    private func handleTouchDowns(inputComponent: InputComponent) {
//        guard !inputComponent.touchDowns.isEmpty else { return }
//        print(self, #function)
//        for (_, set) in inputComponent.touchDowns {
//            for entity in set {
//                entity.add(component: TouchDownComponent())
//            }
//        }
//    }
//
//    private func handleTouchUps(inputComponent: InputComponent) {
//        while !inputComponent.touchDowns.isEmpty {
//            if let touch = inputComponent.touchDowns.first {
//                for entity in touch.value {
//                    entity.add(component: TouchUpComponent())
//                    inputComponent.touchDowns.removeValue(forKey: touch.key)
//                }
//                inputComponent.touchDowns.removeValue(forKey: touch.key)
//            }
//        }
//        while !inputComponent.touchUps.isEmpty {
//            print(self, #function)
//            if let touch = inputComponent.touchUps.first {
//                for entity in touch.value {
//                    entity.add(component: TouchUpComponent())
//                    inputComponent.touchUps.removeValue(forKey: touch.key)
//                }
//                inputComponent.touchDowns.removeValue(forKey: touch.key)
//            }
//        }
//    }
//
//    private func handleTouchMoveds(inputComponent: InputComponent) {
//        while !inputComponent.touchMoveds.isEmpty {
//            print(self, #function)
//        }
//    }
}

final class InputNode: Node {
    required init() {
        super.init()
        components = [
            InputComponent.name: nil_component,
        ]
    }
}
