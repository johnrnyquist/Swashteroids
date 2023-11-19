import Foundation
import Swash


final class FiringControlsSystem: ListIteratingSystem {
    private weak var creator: EntityCreator?
    private weak var bullets: NodeList!

    init(creator: EntityCreator) {
        self.creator = creator
        super.init(nodeClass: GunControlNode.self)
        nodeUpdateFunction = updateNode
    }

    public override func addToEngine(engine: Engine) {
        super.addToEngine(engine: engine)
        bullets = engine.getNodeList(nodeClassType: BulletCollisionNode.self)
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let motion = node[MotionComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self],
			  let input = node[InputComponent.self],
              bullets.numNodes < 5
        else { return }
        gun.shooting = input.triggerIsDown
        gun.timeSinceLastShot += time
        if gun.shooting, gun.timeSinceLastShot >= gun.minimumShotInterval {
           if input.triggerIsDown {
                creator?.createUserBullet(gun, position, motion)
            }
            gun.timeSinceLastShot = 0
        }
    }

    public override func removeFromEngine(engine: Engine) {
        creator = nil
        bullets = nil
    }
}
