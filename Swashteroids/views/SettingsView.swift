//
//  SettingsView.swift
//  Swashteroids
//
//  Created by John Nyquist on 6/26/24.
//

import SwiftUI

struct SettingsView {
    @ObservedObject var gamepadManager: GamepadInputManager
    @State private var curCommand: GameCommand? = nil
    @State private var currentAppState: GameScreen = .playing
    @State private var showAlert = false
    let hide: () -> Void
}

import GameController

extension SettingsView: View {
    var body: some View {
        VStack {
            doneButton
            header
            picker
            commands
            footer
        }.alert(isPresented: $showAlert) { assignmentAlert }
         .onReceive(gamepadManager.$lastPressedButton, perform: updateButtonAssignment)
    }
    var assignmentAlert: Alert {
        Alert(
            title: Text("Assign Function"),
            message: Text("Press a button on your game controller to assign to '\(curCommand?.rawValue ?? "Test")'"),
            dismissButton: .cancel(Text("Cancel"))
        )
    }

    private func updateButtonAssignment(with button: GCControllerButtonInput?) {
        guard let command = curCommand,
              let localizedName = button?.localizedName
        else { return }
        gamepadManager.clearPreviousAssignment(for: localizedName)
        gamepadManager.assignButton(localizedName, to: command)
        curCommand = nil
        showAlert = false
    }

    private var doneButton: some View {
        HStack {
            Spacer()
            Button("Done") {
                let defaults = UserDefaults.standard
                let dictionary = gamepadManager.gameCommandToButtonName.mapKeys { $0.rawValue }
                defaults.set(dictionary, forKey: "GameCommandDict")
                gamepadManager.updateMappings()
                hide()
            }.padding(0)
             .padding(.top, 20)
             .padding(.trailing, 20)
             .disabled(gamepadManager.gameCommandToButtonName.contains { $0.value == nil })
        }
    }
    private var header: some View {
        VStack {
            Text("Controller Settings")
                    .padding(0)
                    .font(.title)
            HStack {
                Text(gamepadManager.gameCommandToButtonName.contains { $0.value == nil }
                     ? "Tap a button to assign a function to it. "
                     : "Tap a button to assign a function to it.")
                        .padding(0)
                        .font(.subheadline)
                Text(gamepadManager.gameCommandToButtonName.contains { $0.value == nil }
                     ? "All values on all screens must be set."
                     : "")
                        .padding(0)
                        .font(.subheadline)
                        .foregroundColor(.red)
            }
        }
    }
    private var picker: some View {
        Picker("Swashteroids State", selection: $currentAppState) {
            ForEach(GameScreen.allCases, id: \.self) { state in
                Text(state.rawValue).tag(state)
            }
        }.padding(0)
    }
    private var commands: some View {
        List(currentAppState.commandsPerScreen, id: \.self) { command in
            Button(action: {
                curCommand = command
                showAlert = true
            }, label: {
                HStack {
                    Text(command.rawValue)
                    Spacer()
                    if let sfSymbolName = gamepadManager.gameCommandToSymbolName(command) {
                        Image(systemName: sfSymbolName)
                    } else {
                        Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundColor(.red)
                    }
                    Text((gamepadManager.gameCommandToButtonName[command] ?? "Not Set") ?? "Not Set")
                }
            })
        }
    }
    private var footer: some View {
        HStack {
            Button("Reset to Previous") {
                gamepadManager.gameCommandToButtonName = gamepadManager.loadSettings()
            }
            Spacer()
            Button("Reset to Defaults") {
                gamepadManager.gameCommandToButtonName = GamepadInputManager.defaultMappings
            }
        }.padding()
    }
}

//#Preview {
//    SettingsView(gamepadManager: GamepadInputManager(game: Swashteroids(scene: GameScene(),
//                                                                   alertPresenter: MockAlertPresenter()),
//                                                size: CGSize(width: 100, height: 100)),
//                 hide: {})
//}
