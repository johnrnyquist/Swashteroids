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

struct ButtonView: View {
    var label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(label)
                        .foregroundColor(.white)
                        .font(.custom("Futura Condensed Medium", size: 32))
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

struct PauseAlert: View {
    var appState: AppStateComponent
    var home: () -> Void
    var resume: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            StatsView(appState: appState)
            HStack(spacing: 19.0) {
                ButtonView(label: "Home", action: home)
                ButtonView(label: "Resume", action: resume)
            }.padding(.horizontal, 20)
        }.frame(width: 300, height: 230)
         .background(Color.black)
         .cornerRadius(20)
         .overlay(
             RoundedRectangle(cornerRadius: 20)
                     .stroke(Color.white, lineWidth: 2)
         )
    }
}

struct PauseAlert_Previews: PreviewProvider {
    static var previews: some View {
        PauseAlert(appState: AppStateComponent(gameSize: .zero,
                                               numShips: 1,
                                               level: 1,
                                               score: 0,
                                               appState: .playing,
                                               shipControlsState: .showingButtons,
                                               randomness: Randomness(seed: 1)),
                    home: {}, resume: {})
    }
}

struct StatsView: View {
    var appState: AppStateComponent
    var body: some View {
        VStack(spacing: 0) {
            Text("Shots Fired: \(appState.numTorpedoesFired)")
            Text("Hit Percentage: \(appState.hitPercentage)%")
            Text("Asteroids Mined: \(appState.numAsteroidsMined)")
            Text("Aliens Destroyed: \(appState.numAliensDestroyed)")
        }.foregroundColor(.white)
            .font(.custom("Futura Condensed Medium", size: 24))
    }
}
