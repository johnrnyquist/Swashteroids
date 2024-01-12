//
// https://github.com/johnrnyquist/Swashteroids
//
// Download Swashteroids from the App Store:
// https://apps.apple.com/us/app/swashteroids/id6472061502
//
// Made with Swash, give it a try!
// https://github.com/johnrnyquist/Swash
//

import UIKit

extension UIColor {
    func lighter(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            if b < 1.0 {
                b = min(b + percentage / 100.0, 1.0)
            }
            if s > 0 {
                s = max(s - percentage / 100.0, 0.0)
            }
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return self
    }
}

extension UIColor {
    func shiftHue(by percentage: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            h = (h + percentage / 100.0).truncatingRemainder(dividingBy: 1.0)
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return self
    }
}