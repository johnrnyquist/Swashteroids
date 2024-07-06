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

extension Engine {
    var playerEntity: Entity? {
        findEntity(named: .player)
    }
    var hud: Entity? {
        findEntity(named: .hud)
    }
    var appStateEntity: Entity {
        guard let entity = findEntity(named: .appState) else {
            fatalError("Engine did not contain `appState` entity!")
        }
        return entity
    }
    // This is a convenience method for accessing the appState component. Because I’m weak. 
    var gameStateComponent: GameStateComponent {
        guard let component = appStateEntity.find(componentClass: GameStateComponent.self) else {
            fatalError("appStateEntity did not contain GameStateComponent!")
        }
        return component
    }
    var shipControlsState: ShipControlsState {
        gameStateComponent.shipControlsState
    }

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
