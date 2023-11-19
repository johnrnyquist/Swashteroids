import Swash

final class GameStateComponent: Component {
    var lives = 0
    var level = 0
    var hits = 0
    var playing = false

    func resetBoard() {
        lives = 3
        level = 0
        hits = 0
        playing = true
    }
}
