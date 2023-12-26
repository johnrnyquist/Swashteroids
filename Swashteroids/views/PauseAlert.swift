//
//  PauseAlert.swift
//  Swashteroids
//
//  Created by John Nyquist on 12/25/23.
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
                    .padding(.horizontal, 20)
        }
    }
}

struct PauseAlert: View {
    var home: () -> Void
    var restart: () -> Void
    var resume: () -> Void
    var body: some View {
        VStack {
            ButtonView(label: "Home", action: home)
//            ButtonView(label: "Restart", action: restart)
            ButtonView(label: "Resume", action: resume)
        }
                .frame(width: 200, height: 200)
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
        PauseAlert(home: {}, restart: {}, resume: {})
    }
}
