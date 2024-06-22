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
    /// This is where you would handle any tasks that need to be processed before the 
    /// game state is updated. This could include input handling or any other 
    /// pre-processing tasks. 
    static let preUpdate = 1
    ///
    ///	This is where the game state is updated. This could include updating the 
    /// positions of game objects, checking for collisions, or any other game logic.
    static let update = 2
    ///
    /// After updating the game state, update the positions of game objects based 
    /// on their velocity and the elapsed time since the last frame.
    static let move = 3
    ///
    /// After moving the game objects, check for and resolve any collisions 
    /// that occurred as a result of the movement. 
    static let resolveCollisions = 4
    ///
    /// Once the game state has been updated and all collisions have been resolved, 
    /// animate the game objects. This could involve updating sprite animations, 
    /// particle effects, etc. 
    static let animate = 5
    ///
    ///  Draw the current state of the game to the screen. 
    static let render = 6
}

// For convenience
extension Int {
    var formattedWithCommas: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "0"
    }
}
