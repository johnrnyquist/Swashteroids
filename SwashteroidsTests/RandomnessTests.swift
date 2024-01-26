//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

@testable import Swashteroids
import XCTest

final class RandomnessTests: XCTestCase {
    var randomness: Randomness!

    override func setUpWithError() throws {
        randomness = Randomness(seed: 1)
    }

    func testNextDouble() {
        for _ in 1...100 {
            let value = randomness.nextDouble()
            XCTAssertGreaterThanOrEqual(value, 0, "Generated value is less than 0")
            XCTAssertLessThan(value, 1, "Generated value is not less than 1")
        }
    }

    func testNextIntUpTo() {
        let max = 10
        for _ in 1...100 {
            let value = randomness.nextInt(upTo: max)
            XCTAssertGreaterThanOrEqual(value, 0, "Generated value is less than 0")
            XCTAssertLessThan(value, max, "Generated value is not less than \(max)")
        }
    }

    func testNextIntFromUpTo() {
        let min = 5
        let max = 10
        for _ in 1...100 {
            let value = randomness.nextInt(from: min, upTo: max)
            XCTAssertGreaterThanOrEqual(value, min, "Generated value is less than \(min)")
            XCTAssertLessThan(value, max, "Generated value is not less than \(max)")
        }
    }

    func testNextIntFromThrough() {
        let min = 5
        let max = 10
        for _ in 1...100 {
            let value = randomness.nextInt(from: min, through: max)
            XCTAssertGreaterThanOrEqual(value, min, "Generated value is less than \(min)")
            XCTAssertLessThanOrEqual(value, max, "Generated value is greater than \(max)")
        }
    }
}
