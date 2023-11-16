import Foundation
import Swash


class FiringControlsSystem: ListIteratingSystem {
    private var keyPoll: KeyPoll
    private var creator: EntityCreator?
    private var bullets: NodeList!

    init(keyPoll: KeyPoll, creator: EntityCreator) {
        self.keyPoll = keyPoll
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
              bullets.numNodes < 5
        else { return }
        gun.shooting = keyPoll.triggerIsDown || keyPoll.aftTriggerIsDown
        gun.timeSinceLastShot += time
        if gun.shooting,
           gun.timeSinceLastShot >= gun.minimumShotInterval {
            if keyPoll.aftTriggerIsDown {
                creator?.createUserBullet(gun, position, motion, dir: -1)

            } else if keyPoll.triggerIsDown {
                creator?.createUserBullet(gun, position, motion)
                
            }
            gun.timeSinceLastShot = 0
        }
    }
}
