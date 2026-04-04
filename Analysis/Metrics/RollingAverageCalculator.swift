import Foundation

struct RollingAverageCalculator {
    func average<T: BinaryFloatingPoint>(for values: [T]) -> Double? {
        guard values.isEmpty == false else {
            return nil
        }

        return Double(values.reduce(0, +)) / Double(values.count)
    }
}
