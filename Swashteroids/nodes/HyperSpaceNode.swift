//
//  HyperSpaceNode.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/15/23.
//

import Swash

class HyperSpaceNode: Node {
	required init() {
		super.init()
		components = [
			HyperSpaceComponent.name: nil_component,
			PositionComponent.name: nil_component,
			InputComponent.name: nil_component
		]
	}
}
