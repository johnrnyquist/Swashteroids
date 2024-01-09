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

// System Priorities
extension Int {
	static let preUpdate = 1
	static let update = 2
	static let move = 3
	static let resolveCollisions = 4
	static let stateMachines = 5
	static let animate = 6
	static let render = 7
}

// For convenience
extension Int {
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
