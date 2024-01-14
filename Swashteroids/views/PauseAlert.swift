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
                    .padding(.horizontal, 20)
        }
    }
}

struct PauseAlert: View {
    var hitPercentage: Int
    var home: () -> Void
    var resume: () -> Void
    var body: some View {
        VStack(spacing: 10) {
            ButtonView(label: "Home", action: home)
            ButtonView(label: "Resume", action: resume)
            Text("Hit percentage: \(hitPercentage)%")
                    .foregroundColor(.white)
                    .font(.custom("Futura Condensed Medium", size: 24))
                    .padding(.top, 10)
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
        PauseAlert(hitPercentage: 0, home: {}, resume: {})
    }
}
