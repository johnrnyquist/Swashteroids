//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import SwiftUI
import GameController

struct PauseAlert: View {
    var appState: GameStateComponent
    var home: () -> Void
    var resume: () -> Void
    var showSettings: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            StatsView(appState: appState)
            HStack(spacing: 19.0) {
                ButtonView(label: "Home", action: home)
                ButtonView(label: "Resume", action: resume)
            }.padding(.horizontal, 20)
            if GCController.isGameControllerConnected() {
                ButtonView(label: "Controller Settings", action: showSettings)
                        .padding(.horizontal, 20)
            }
        }.frame(width: 320, height: 320)
         .background(Color.black)
         .cornerRadius(20)
         .overlay(
             RoundedRectangle(cornerRadius: 20)
                     .stroke(Color.white, lineWidth: 2)
         )
    }
}

struct StatsView: View {
    var appState: GameStateComponent
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Level: \(appState.level)")
                Text("    ")
                Text("Score: \(appState.score.formattedWithCommas)")
            }.font(.custom("Futura Condensed Medium", size: 30))
            Text("Asteroids Mined: \(appState.numAsteroidsMined.formattedWithCommas)")
            Text("Aliens Destroyed: \(appState.numAliensDestroyed.formattedWithCommas)")
            Text("Shots Fired: \(appState.numTorpedoesPlayerFired.formattedWithCommas)")
            Text("Hit Percentage: \(appState.hitPercentage.formattedWithCommas)%")
            Text("Play Time: \(getTime(appState.timePlayed))")
        }.foregroundColor(.white)
         .font(.custom("Futura Condensed Medium", size: 24))
    }

    func getTime(_ time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
//        if hours > 0 {
//            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
//        } else if minutes > 0 {
//            return String(format: "%02i:%02i", minutes, seconds)
//        } else {
//            return String(format: "%02i", seconds)
//        }
    }
}

struct ButtonView: View {
    var label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                        .foregroundColor(.white)
                        .font(.custom("Futura Condensed Medium", size: 22))
                        .padding(.vertical, 5)
                Spacer()
            }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white, lineWidth: 2)
                    )
        }
    }
}

struct PauseAlert_Previews: PreviewProvider {
    static var previews: some View {
        PauseAlert(appState: GameStateComponent(config: GameConfig(gameSize: .zero)),
                   home: {}, resume: {}, showSettings: {})
    }
}
