
extension Double {
    func clamped(v1: Double, v2: Double) -> Double {
        let min = v1 < v2 ? v1 : v2
        let max = v1 > v2 ? v1 : v2
        return self < min ? min : (self > max ? max : self)
    }

    func clamped(to r: ClosedRange<Double>) -> Double {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (self > max ? max : self)
    }
}
