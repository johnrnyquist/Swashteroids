import Swash

extension Engine {
    var ship: Entity? {
        get { getEntity(named: .ship) }
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
