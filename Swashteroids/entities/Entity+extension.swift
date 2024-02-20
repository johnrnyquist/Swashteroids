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

extension Engine {
    /// Removes all entities of a given type from the engine.
    /// - Parameter nodeType: The type of node to remove.
    /// - Note: This method is used only in Transition+GameOver.swift.
    func clearEntities(of nodeType: Node.Type?) {
        guard let nodeType = nodeType else { return }
        let nodes = getNodeList(nodeClassType: nodeType)
        var node = nodes.head
        while let currentNode = node {
            remove(entity: currentNode.entity!)
            node = currentNode.next
        }
    }
}
