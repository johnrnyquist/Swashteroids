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
    var ship: ShipEntity? {
        getEntity(named: .ship) as? ShipEntity
    }
    var gameOver: Entity? {
        getEntity(named: .gameOver)
    }
    var hud: Entity? {
        getEntity(named: .hud)
    }
    var appState: Entity? {
        getEntity(named: .appState)
    }
    var input: Entity? {
        getEntity(named: .input)
    }

    func removeEntities(named names: [EntityName]) {
        for name in names {
            if let entity = getEntity(named: name) {
                remove(entity: entity)
            } else {
                print(#function, #line, "WARNING: engine did not contain \(name) entity!")
            }
        }
    }
}
