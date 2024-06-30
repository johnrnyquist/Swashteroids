//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

enum GameCommand: String, CaseIterable {
    // Playing
    case fire = "Fire"
    case thrust = "Thrust"
    case hyperspace = "Hyperspace"
    case left = "Left"
    case right = "Right"
    case pause = "Pause"
    case flip = "Flip"
    // Alert
    case home = "Home"
    case resume = "Resume"
    case settings = "Settings"
    // Start
    case buttons = "Buttons"
    case noButtons = "No Buttons"
    // Info
    case `continue` = "Continue"
}

enum GameState: String, CaseIterable {
    case start = "Start Screen"
    case infoButtons = "Buttons Information Screen"
    case infoNoButtons = "No Buttons Information Screen"
    case playing = "Playing Screen"
    case gameOver = "Game Over Screen"
    var commandsPerScreen: [GameCommand] {
        switch self {
            case .start:
                return [.buttons, .noButtons]
            case .infoButtons:
                return [.continue]
            case .infoNoButtons:
                return [.continue]
            case .playing:
                return [.fire, .thrust, .hyperspace, .left, .right, .pause, .flip]
            case .gameOver:
                return [.pause, .home, .settings, .resume]
        }
    }
}

struct SettingsView: View {
    @ObservedObject var gamePadManager: GamePadManager
    @State private var curCommand: GameCommand? = nil
    @State private var currentAppState: GameState = .playing
    @State private var showAlert = false
    let hide: () -> Void
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    // Save to UserDefaults
                    let defaults = UserDefaults.standard
                    let dictionary = gamePadManager.gameCommandToElementName.mapKeys { $0.rawValue }
                    defaults.set(dictionary, forKey: "GameCommandDict")
                    hide()
                }.padding(0)
                 .padding(.top, 20)
                 .padding(.trailing, 20)
            }
            Text("Settings")
                    .padding(0)
                    .font(.title)
            Text("Tap a button to assign a function to it.")
                    .padding(0)
                    .font(.subheadline)
            Picker("Swashteroids State", selection: $currentAppState) {
                ForEach(GameState.allCases, id: \.self) { state in
                    Text(state.rawValue).tag(state)
                }
            }.padding(0)
            List(currentAppState.commandsPerScreen, id: \.self) { command in
                HStack {
                    Text(command.rawValue)
                    Spacer()
                    Button(action: {
                        curCommand = command
                        showAlert = true
                    }) {
                        HStack {
                            if let commandName = gamePadManager.gameCommandToElementName[command],
                               let sfSymbolName = gamePadManager.elementNameToSymbolName[
                                   commandName ?? "exclamationmark.octagon.fill"
                                   ] {
                                Image(systemName: sfSymbolName)
                            }
                            Text((gamePadManager.gameCommandToElementName[command] ?? "Not Set") ?? "Not Set")
                        }
                    }
                }
            }
            HStack {
                Button("Reset to Previous") {
                    gamePadManager.gameCommandToElementName = gamePadManager.loadSettings()
                }
                Spacer()
                Button("Reset to Defaults") {
                    gamePadManager.gameCommandToElementName = GamePadManager.defaultMappings
                }
            }.padding()
        }.alert(isPresented: $showAlert) {
             Alert(
                 title: Text("Assign Function"),
                 message: Text("Press a button on your game controller to assign to '\(curCommand?.rawValue ?? "Test")'"),
                 dismissButton: .cancel(Text("Cancel"))
             )
         }
         .onReceive(gamePadManager.$lastElementPressed) { str in
             guard let command = curCommand,
                   let str else { return }
             gamePadManager.gameCommandToElementName[command] = str
             curCommand = nil
             showAlert = false
             print("Updated \(command.rawValue) to \(str)")
         }
    }
}

#Preview {
    SettingsView(gamePadManager: GamePadManager(game: Swashteroids(scene: GameScene(),
                                                                   alertPresenter: MockAlertPresenter()),
                                                size: CGSize(width: 100, height: 100)),
                 hide: {})
}
