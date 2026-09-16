import Foundation

public enum SRS {
    public static func next(easiness: Double, interval: Int, reps: Int, quality: Int, now: Date = Date(), calendar: Calendar = .current) -> (easiness: Double, interval: Int, reps: Int, due: Date) {
        let q = max(0, min(5, quality))
        var ef = max(1.3, easiness + (0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)))
        var itv: Int
        if q < 3 {
            itv = 1
            ef = max(1.3, ef - 0.2)
        } else {
            itv = reps == 0 ? 1 : reps == 1 ? 3 : Int((Double(max(1, interval)) * ef).rounded())
        }
        let due = calendar.date(byAdding: .day, value: itv, to: now) ?? now
        return (ef, itv, q >= 3 ? reps + 1 : 0, due)
    }
}

public enum QuotaLogic {
    public static let freeDaily = 3

    public static func canUnlock(pro: Bool, freeRitualsUsed: Int) -> Bool {
        pro || freeRitualsUsed < freeDaily
    }
}

public enum StreakLogic {
    public static func evaluate(lastActiveDay: Date?, currentStreak: Int, today: Date, calendar: Calendar = .current) -> Int {
        guard let last = lastActiveDay else { return 0 }
        let lastDay = calendar.startOfDay(for: last)
        let todayDay = calendar.startOfDay(for: today)
        let diff = calendar.dateComponents([.day], from: lastDay, to: todayDay).day ?? 0
        if diff == 0 { return currentStreak }
        if diff == 1 { return currentStreak + 1 }
        return 1
    }
}

public enum NonceGuard {
    public static let expiry: TimeInterval = 600

    public static func isValid(timestamp: Date, now: Date = Date()) -> Bool {
        now.timeIntervalSince(timestamp) <= expiry && now.timeIntervalSince(timestamp) >= -expiry
    }
}
