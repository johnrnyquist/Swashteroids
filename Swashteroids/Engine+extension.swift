//
//  Engine+extension.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/18/23.
//

import Swash


extension Engine {
	public var ship: Entity? {
		get { self.getEntity(named: "ship") }
	}
	public var wait: Entity? {
		get { self.getEntity(named: "wait") }
	}
}
