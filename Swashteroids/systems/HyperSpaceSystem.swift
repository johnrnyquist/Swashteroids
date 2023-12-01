//
//  HyperSpaceSystem.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/15/23.
//

import Swash
import SpriteKit

final class HyperSpaceSystem: ListIteratingSystem {
	private var sound = SKAction.playSoundFileNamed("hyperspace.wav", waitForCompletion: false)
	private weak var scene: SKScene!

	init(scene: SKScene) {
		self.scene = scene
		super.init(nodeClass: HyperSpaceNode.self)
		nodeUpdateFunction = updateNode
	}

	private func updateNode(node: Node, time: TimeInterval) {
		guard let position = node[PositionComponent.self],
			  let hyperSpace = node[HyperSpaceComponent.self],
			  let input = node[InputComponent.self]
		else { return }
		input.hyperSpaceIsDown = false
		position.position.x += hyperSpace.x
		position.position.y += hyperSpace.y
		node.entity?.remove(componentClass: HyperSpaceComponent.self)
		scene.run(sound) // This probably should be elsewhere
	}

	override public func removeFromEngine(engine: Engine) {
		scene = nil
	}
}
