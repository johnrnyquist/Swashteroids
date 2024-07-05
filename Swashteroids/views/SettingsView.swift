//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

public enum GameState: String, CaseIterable {
    case start = "Start Screen"
    case infoButtons = "Buttons Information Screen"
    case infoNoButtons = "No Buttons Information Screen"
    case playing = "Playing Screen"
    case gameOver = "Game Over Screen"
    var commandsPerState: [GameCommand] {
        switch self {
            case .start:
                return [.play]
            case .infoButtons:
                return [.play]
            case .infoNoButtons:
                return [.play]
            case .playing:
                return [.fire, .thrust, .hyperspace, .left, .right, .pause, .flip, .home, .settings, .resume]
            case .gameOver:
                return [.pause, .home, .settings, .resume]
        }
    }
}

struct SettingsView: View {
    @ObservedObject var gamePadManager: GamePadInputManager
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
                    let dictionary = gamePadManager.gameCommandToButtonName.mapKeys { $0.rawValue }
                    defaults.set(dictionary, forKey: "GameCommandDict")
                    gamePadManager.updateMappings()
                   hide()
                }.padding(0)
                 .padding(.top, 20)
                 .padding(.trailing, 20)
                 .disabled(gamePadManager.gameCommandToButtonName.contains { $0.value == nil })
            }
            Text("Controller Settings")
                    .padding(0)
                    .font(.title)
            HStack {
                Text(gamePadManager.gameCommandToButtonName.contains { $0.value == nil }
                     ? "Tap a button to assign a function to it. "
                     : "Tap a button to assign a function to it.")
                        .padding(0)
                        .font(.subheadline)
                Text(gamePadManager.gameCommandToButtonName.contains { $0.value == nil }
                     ? "All values on all screens must be set."
                     : "")
                        .padding(0)
                        .font(.subheadline)
                        .foregroundColor(.red)
            }
            Picker("Swashteroids State", selection: $currentAppState) {
                ForEach(GameState.allCases, id: \.self) { state in
                    Text(state.rawValue).tag(state)
                }
            }.padding(0)
            List(currentAppState.commandsPerState, id: \.self) { command in
                Button(action: {
                    curCommand = command
                    showAlert = true
                }, label: {
                    HStack {
                        Text(command.rawValue)
                        Spacer()
                        if let sfSymbolName = gamePadManager.gameCommandToSymbolName(command) {
                            Image(systemName: sfSymbolName)
                        } else {
                            Image(systemName: "exclamationmark.octagon.fill")
                                    .foregroundColor(.red)
                        }
                        Text((gamePadManager.gameCommandToButtonName[command] ?? "Not Set") ?? "Not Set")
                    }
                })
            }
            HStack {
                Button("Reset to Previous") {
                    gamePadManager.gameCommandToButtonName = gamePadManager.loadSettings()
                }
                Spacer()
                Button("Reset to Defaults") {
                    gamePadManager.gameCommandToButtonName = GamePadInputManager.defaultMappings
                }
            }.padding()
        }.alert(isPresented: $showAlert) {
            Alert(
                title: Text("Assign Function"),
                message: Text("Press a button on your game controller to assign to '\(curCommand?.rawValue ?? "Test")'"),
                dismissButton: .cancel(Text("Cancel"))
            )
        }.onReceive(gamePadManager.$lastPressedButton) { button in
            guard let command = curCommand,
                  let localizedName = button?.localizedName
            else { return }
            // Iterate over the dictionary and nil out the previous place where localizedName was used
            for (command, buttonName) in gamePadManager.gameCommandToButtonName where gamePadManager.game.gameState.commandsPerState.contains(command) {
                if buttonName == localizedName {
                    gamePadManager.gameCommandToButtonName[command] = nil_string
                }
            }
            // Assign the new str to the current command
            gamePadManager.gameCommandToButtonName[command] = localizedName
            curCommand = nil
            showAlert = false
            print("Updated \(command.rawValue) to \(localizedName)")
        }
    }
}

public let nil_string: String? = nil
//#Preview {
//    SettingsView(gamePadManager: GamePadInputManager(game: Swashteroids(scene: GameScene(),
//                                                                   alertPresenter: MockAlertPresenter()),
//                                                size: CGSize(width: 100, height: 100)),
//                 hide: {})
//}
