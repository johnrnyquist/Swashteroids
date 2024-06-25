////
//// https://github.com/johnrnyquist/Swashteroids
////
//// Download Swashteroids from the App Store:
//// https://apps.apple.com/us/app/swashteroids/id6472061502
////
//// Made with Swash, give it a try!
//// https://github.com/johnrnyquist/Swash
////
//
//import Foundation
//import Swash
//
//final class MakeDecisionSystem: ListIteratingSystem {
//    init() {
//        super.init(nodeClass: MakeDecisionNode.self)
//        nodeUpdateFunction = updateNode
//    }
//
//    func updateNode(node: Node, time: TimeInterval) {
//        guard let _ = node[MakeDecisionComponent.self],
//              let reactionTimeComponent = node[ReactionTimeComponent.self],
//              let entity = node.entity
//        else { return }
//        entity.remove(componentClass: MakeDecisionComponent.self)
//        // In theory, I'll have more options here in the future
//        entity.add(component: PickTargetComponent())
//    }
//}
//
//
//
//
