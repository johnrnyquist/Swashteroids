//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Foundation
import Swash
import SpriteKit

final class FiringSystem: System {
    private weak var creator: (TorpedoCreator & PowerUpCreator)?
    private weak var firingNodes: NodeList?

    init(creator: TorpedoCreator & PowerUpCreator) {
        self.creator = creator
    }

    override public func addToEngine(engine: Engine) {
        firingNodes = engine.getNodeList(nodeClassType: FiringNode.self)
    }

    override public func update(time: TimeInterval) {
        var node = firingNodes?.head
        while let currentNode = node {
            updateNode(node: currentNode, time: time)
            node = currentNode.next
        }
    }

    private func updateNode(node: Node, time: TimeInterval) {
        guard let velocity = node[VelocityComponent.self],
              let position = node[PositionComponent.self],
              let gun = node[GunComponent.self],
              let _ = node[FireDownComponent.self]
        else { return }
        node.entity?.remove(componentClass: FireDownComponent.self)
        let pos = PositionComponent(x: position.x, y: position.y, z: .asteroids, rotationDegrees: position.rotationDegrees)
        creator?.createTorpedo(gun, pos, velocity)
        gun.numTorpedoes -= 1
    }
}

//HACK this is not used but for reference when I actually implement a new power-up
func shootLaser(scene: SKScene, ship: SKSpriteNode, size: CGSize, children: [SKNode]) {
    // Maximum length of the laser (half the screen width)
    let maxLaserLength = size.width / 2
    // Calculate the direction of the laser based on the ship's rotation
    let angle = ship.zRotation
    let dx = maxLaserLength * cos(angle)
    let dy = maxLaserLength * sin(angle)
    // Initial end point of the laser if it doesn't hit any asteroid
    var laserEndPoint = CGPoint(x: ship.position.x + dx, y: ship.position.y + dy)
    // Placeholder for the first asteroid hit by the laser
    var firstAsteroid: SKSpriteNode?
    // Placeholder for the shortest distance from the ship to an asteroid
    var shortestDistance = CGFloat.infinity
    // Iterate over all child nodes named "asteroid"
    for node in children where node.name == "asteroid" {
        // Calculate the vector from the ship to the asteroid
        let dx = node.position.x - ship.position.x
        let dy = node.position.y - ship.position.y
        // Calculate the distance from the ship to the asteroid
        let distance = sqrt(dx * dx + dy * dy)
        // Calculate the angle from the ship to the asteroid
        let asteroidAngle = atan2(dy, dx)
        // Calculate the difference between the asteroid angle and the ship's rotation angle
        let angleDifference = abs(asteroidAngle - angle)
        // Check if the asteroid is in the path of the laser (within a certain angle threshold)
        if angleDifference < 0.1 {  // adjust the threshold as needed
            // Cast the node to SKSpriteNode
            let asteroid = node as! SKSpriteNode
            // Get the radius of the asteroid
            let radius = asteroid.size.width / 2  // replace with your radius property
            // Check if the asteroid is within the maximum laser length
            if distance - radius <= maxLaserLength {
                // Update the first asteroid and shortest distance
                firstAsteroid = asteroid
                shortestDistance = distance
                // Update the end point of the laser to the position of the asteroid
                laserEndPoint = node.position
            }
        }
    }
    // Create a path from the ship to the end point
    let path = UIBezierPath()
    path.move(to: ship.position)
    path.addLine(to: laserEndPoint)
    // Create a shape node with that path
    let laser = SKShapeNode(path: path.cgPath)
    laser.strokeColor = .red
    laser.lineWidth = 2.0
    // Add the laser to the scene
    scene.addChild(laser)
    // Remove the laser after a delay
    let wait = SKAction.wait(forDuration: 0.5)
    let remove = SKAction.removeFromParent()
    let sequence = SKAction.sequence([wait, remove])
    laser.run(sequence)
}
