//
//  HyperSpaceComponent.swift
//  Swashteroids
//
//  Created by John Nyquist on 11/15/23.
//

import Swash
import Foundation

final class HyperSpaceJumpComponent: Component {
	let x = Double.random(in: 0...1024)
	let y = Double.random(in: 0...1024)
}

final class HyperSpaceEngineComponent: Component {}