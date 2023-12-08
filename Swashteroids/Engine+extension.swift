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
        get { getEntity(named: .ship) as? ShipEntity }
    }
    var gameOver: Entity? {
        get { getEntity(named: .gameOver) }
    }
    var hud: Entity? {
        get { getEntity(named: .hud) }
    }

    func removeEntities(named names: [EntityName]) {
        for name in names {
            if let entity = getEntity(named: name) {
                removeEntity(entity: entity)
            } else {
                print("WARNING: engine did not contain \(name) entity!")
            }
        }
    }
}
