import SwiftUI
import SwiftData
import FamilyControls

struct TodayView: View {
    @Binding var showPaywall: Bool
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dailyState = DailyStateModel()
    @StateObject private var guardModel = GuardModel.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPicker = false
    @State private var showSOS = false

    private var verse: Verse {
        let day = VerseLibrary.currentDayIndex
        if let cached = AppGroupStore.cachedVerseOfDay(dayIndex: day) { return cached }
        let v = VerseLibrary.randomToday()
        AppGroupStore.cacheVerseOfDay(v, dayIndex: day)
        return v
    }

    private var recentDays: [Bool] {
        let events = (try? modelContext.fetchCount(FetchDescriptor<UnlockEvent>())) ?? 0
        _ = events
        var flags: [Bool] = []
        let calendar = Calendar.current
        for offset in (0..<84).reversed() {
            if let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) {
                let nextDay = day.addingTimeInterval(86400)
                let descriptor = FetchDescriptor<UnlockEvent>(predicate: #Predicate { event in
                    event.timestamp >= day && event.timestamp < nextDay
                })
                let count = (try? modelContext.fetchCount(descriptor)) ?? 0
                flags.append(count > 0)
            }
        }
        return flags
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    header
                    Components.VerseCard(verse: verse)
                    streakCard
                    quotaCard
                    guardButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .background(Theme.porcelain)
            .navigationTitle("Today")
            .sheet(isPresented: $showPicker) {
                AppPickerScreen()
            }
            .confirmationDialog(
                "Use SOS Grace for a 10-minute exemption?",
                isPresented: $showSOS,
                titleVisibility: .visible
            ) {
                Button("Grace covers today") { useSOS() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("It will be recorded gently in your journey. No shame.")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(greeting)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
            Text("Pray before you scroll.")
                .font(Theme.serifLarge)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning."
        case 12..<18: return "Good afternoon."
        default: return "Good evening."
        }
    }

    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("\(dailyState.state.currentStreak)", systemImage: "flame.fill")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.gold)
                    .labelStyle(.titleAndIcon)
                Text(dailyState.state.currentStreak == 1 ? "day of prayer" : "day streak")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Components.QuotaRing(used: dailyState.state.freeRitualsUsed, total: QuotaLogic.freeDaily, isPro: purchaseManager.isPro)
            }
            Components.StreakGrid(days: recentDays, columns: 12)
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
        .onAppear { dailyState.attach(context: modelContext); dailyState.reload(); dailyState.rollIfNeeded() }
    }

    private var quotaCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Free forever")
                    .font(.headline)
                Text("Unlimited guarding · 3 ritual unlocks a day · full verse library")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !purchaseManager.isPro {
                Button("Pro") { showPaywall = true }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.gold)
                    .accessibilityLabel("Upgrade to Pro")
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var guardButton: some View {
        VStack(spacing: 12) {
            Button {
                showPicker = true
            } label: {
                Label(guardModel.selection.applicationTokens.isEmpty ? "Guard apps" : "Apps guarded · adjust",
                      systemImage: "door.left.hand.open")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)

            Button("Need an emergency pass?") {
                showSOS = true
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Use SOS Grace emergency unlock")
        }
    }

    private func useSOS() {
        let deadline = Date().addingTimeInterval(600)
        GuardModel.shared.clearShield()
        AppGroupStore.focusWindowEndsAt = deadline
        RitualStore.recordSOS(context: modelContext)
        try? GuardScheduler().schedule(focusMinutes: 10)
        dailyState.reload()
    }
}

struct AppPickerScreen: View {
    @StateObject private var guardModel = GuardModel.shared
    @Environment(\.dismiss) private var dismiss
    @State private var pickerSelection = FamilyActivitySelection()
    @State private var loaded = false

    var body: some View {
        NavigationStack {
            FamilyActivityPicker(selection: $pickerSelection)
                .navigationTitle("Choose what to guard")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guard these") {
                            guardModel.saveSelection(pickerSelection)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
                .onAppear {
                    if !loaded {
                        pickerSelection = guardModel.selection
                        loaded = true
                        if !guardModel.authorized {
                            Task { await guardModel.authorize() }
                        }
                    }
                }
        }
    }
}
