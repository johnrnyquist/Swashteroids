import Swash

final class GameStateComponent: Component {
    var ships = 0
    var level = 0
    var hits = 0
    var playing = false

    func resetBoard() {
        ships = 3
        level = 0
        hits = 0
    }
}
