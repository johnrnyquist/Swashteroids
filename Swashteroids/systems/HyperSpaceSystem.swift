//
//  HyperSpaceSystem.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/15/23.
//

import Foundation
import Swash


class HyperSpaceSystem: ListIteratingSystem {
	var config: GameConfig!

	init(config: GameConfig) {
		super.init(nodeClass: HyperSpaceNode.self)
		self.config = config
		nodeUpdateFunction = updateNode
	}

	private func updateNode(node: Node, time: TimeInterval) {
		guard let position = node[PositionComponent.self],
			  let hyperSpace = node[HyperSpaceComponent.self]
		else { return }
		position.position.x += hyperSpace.x
		position.position.y += hyperSpace.y
		node.entity?.remove(componentClass: HyperSpaceComponent.self)
	}
}
