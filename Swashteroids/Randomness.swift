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

/// `Randomness` is a class for generating random numbers. 
// It is really just a wrapper around the `srand48` and `drand48` functions.
class Randomness {
    /// Initializes a new instance of `Randomness` and sets the seed for the random number generator.
    /// - Parameter seed: The seed for the random number generator.
    init(seed: Int) {
        srand48(seed)
    }

    /// Generates a random double between 0 and 1.
    /// - Returns: A random `Double` between 0 and 1.
    func nextDouble() -> Double {
        drand48()
    }

    /// Generates a random integer from 0 up to but not including the specified maximum.
    /// - Parameter max: The upper bound of the range.
    /// - Returns: A random `Int` from 0 up to but not including `max`.
    func nextInt(upTo max: Int) -> Int {
        Int(drand48() * Double(max))
    }

    /// Generates a random integer from the specified minimum up to but not including the specified maximum.
    /// - Parameters:
    ///   - min: The lower bound of the range.
    ///   - max: The upper bound of the range.
    /// - Returns: A random `Int` from `min` up to but not including `max`.
    func nextInt(from min: Int, upTo max: Int) -> Int {
        Int(drand48() * Double(max - min)) + min
    }

    /// Generates a random integer from the specified minimum up to and including the specified maximum.
    /// - Parameters:
    ///   - min: The lower bound of the range.
    ///   - max: The upper bound of the range.
    /// - Returns: A random `Int` from `min` up to and including `max`.
    func nextInt(from min: Int, through max: Int) -> Int {
        Int(drand48() * Double(max - min + 1)) + min
    }

    /// Generates a random `Double` within the specified range.
    /// - Parameters:
    ///   - min: The lower bound of the range.
    ///   - max: The upper bound of the range.
    /// - Returns: A random `TimeInterval` from `min` through `max`.
    func nextDouble(from min: Double, through max: Double) -> Double {
        min + (drand48() * (max - min))
    }

    /// Generates a Boolean value, which is `true` or `false` with equal likelihood.
    /// - Returns: A random `Bool`.
    /// - Note: This method is equivalent to calling `nextDouble()` and checking if the result is less than 0.5.
    /// - SeeAlso: `nextDouble()`
    func nextBool() -> Bool {
        drand48() < 0.5
    }
}