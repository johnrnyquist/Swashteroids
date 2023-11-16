//
//  HyperSpaceSystem.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/15/23.
//

import Swash
import SpriteKit

class HyperSpaceSystem: ListIteratingSystem {
	var config: GameConfig
	var sound = SKAction.playSoundFileNamed("hyperspace.wav", waitForCompletion: false)
	var scene: SKScene

	init(config: GameConfig, scene: SKScene) {
		self.config = config
		self.scene = scene
		super.init(nodeClass: HyperSpaceNode.self)
		nodeUpdateFunction = updateNode
	}

	private func updateNode(node: Node, time: TimeInterval) {
		guard let position = node[PositionComponent.self],
			  let hyperSpace = node[HyperSpaceComponent.self]
		else { return }
		position.position.x += hyperSpace.x
		position.position.y += hyperSpace.y
		node.entity?.remove(componentClass: HyperSpaceComponent.self)
		scene.run(sound)
	}
}
