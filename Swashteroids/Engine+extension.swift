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
    var ship: Entity? {
        findEntity(named: .player)
    }
    var gameOver: Entity? {
        findEntity(named: .gameOver)
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
    var appStateComponent: SwashteroidsStateComponent {
        guard let component = appStateEntity.find(componentClass: SwashteroidsStateComponent.self) else {
            fatalError("appState entity did not contain AppStateComponent!")
        }
        return component
    }
    var input: Entity? {
        findEntity(named: .input)
    }
}
