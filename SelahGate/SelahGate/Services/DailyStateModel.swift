import Combine
import Foundation
import SwiftData

@MainActor
final class DailyStateModel: ObservableObject {
    @Published var state = DailyState()
    private var context: ModelContext?

    func attach(context: ModelContext) {
        if self.context == nil {
            self.context = context
            reload()
        }
    }

    func reload() {
        guard let context else { return }
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyState>(predicate: #Predicate { $0.date == today })
        if let existing = try? context.fetch(descriptor).first {
            state = existing
        } else {
            let fresh = DailyState()
            fresh.date = today
            context.insert(fresh)
            try? context.save()
            state = fresh
        }
    }

    var isPro: Bool { PurchaseManager.shared.isPro }

    var canUnlock: Bool {
        QuotaLogic.canUnlock(pro: isPro, freeRitualsUsed: state.freeRitualsUsed)
    }

    func rollIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if !Calendar.current.isDate(state.date, inSameDayAs: today) {
            state.date = today
            state.freeRitualsUsed = 0
            state.freezeUsed = false
            try? context?.save()
        }
    }

    func useStreakFreeze() {
        guard !state.freezeUsed else { return }
        state.freezeUsed = true
        try? context?.save()
    }
}
