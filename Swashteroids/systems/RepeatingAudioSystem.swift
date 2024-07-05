//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import Swash
import SpriteKit
import SwiftySound

final class RepeatingAudioSystem: ListIteratingSystem {
    init() {
        super.init(nodeClass: RepeatingAudioNode.self)
        nodeUpdateFunction = updateNode
    }

    func updateNode(node: Node, time: TimeInterval) {
        guard let audio = node[RepeatingAudioComponent.self]
        else { return }
        switch audio.state {
            case .shouldBegin:
                audio.state = .playing
                if audio.sound?.playing == false {
                    audio.sound?.play(numberOfLoops: -1)
                }
                audio.sound?.volume = 1
            case .shouldStop:
                audio.state = .notPlaying
                audio.sound?.volume = 0
            case .notPlaying, .playing:
                break
        }
    }
}


