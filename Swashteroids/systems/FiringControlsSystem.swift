import Foundation
import Swash


class FiringControlsSystem: ListIteratingSystem {
    private var creator: EntityCreator?
    private var bullets: NodeList!

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
        gun.shooting = input.triggerIsDown || input.aftTriggerIsDown
        gun.timeSinceLastShot += time
        if gun.shooting,
           gun.timeSinceLastShot >= gun.minimumShotInterval {
            if input.aftTriggerIsDown {
                creator?.createUserBullet(gun, position, motion, dir: -1)

            } else if input.triggerIsDown {
                creator?.createUserBullet(gun, position, motion)
                
            }
            gun.timeSinceLastShot = 0
        }
    }
}
