import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [UnlockEvent]
    @StateObject private var dailyState = DailyStateModel()

    private var calendar: Calendar { Calendar.current }

    private var todayEvents: [UnlockEvent] {
        let start = calendar.startOfDay(for: Date())
        return events.filter { $0.timestamp >= start }
    }

    private var resistedCount: Int {
        todayEvents.filter { !$0.usedSOS }.count
    }

    private var weekMinutes: Int {
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return events.filter { $0.timestamp >= weekAgo }.reduce(0) { $0 + $1.ritualSeconds } / 60
    }

    private var topMood: (String, Int)? {
        let counts = Dictionary(grouping: events, by: { $0.moodTag }).mapValues(\.count)
        return counts.max { $0.value < $1.value }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCard
                    heatmapCard
                    moodsCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .background(Theme.porcelain)
            .navigationTitle("Journey")
            .onAppear { dailyState.attach(context: modelContext); dailyState.reload(); dailyState.rollIfNeeded() }
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 16) {
            HStack {
                statBlock(value: "\(dailyState.state.currentStreak)", label: "Streak", icon: "flame.fill")
                statBlock(value: "\(resistedCount)", label: "Scrolls resisted today", icon: "hand.raised.fill")
                statBlock(value: "\(weekMinutes)m", label: "Prayer this week", icon: "clock.fill")
            }
            if dailyState.state.longestStreak > dailyState.state.currentStreak {
                Text("Longest streak: \(dailyState.state.longestStreak) days")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func statBlock(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(Theme.gold)
            Text(value)
                .font(.title2.weight(.bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Every day begins again", systemImage: "square.grid.3x3.square")
                .font(.headline)
            Components.StreakGrid(days: last91Days(), columns: 13)
            Text("Day 0 is still holy. Begin again.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var moodsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What your heart has carried", systemImage: "heart.text.square")
                .font(.headline)
            if events.isEmpty {
                Text("Complete your first ritual to start the journey.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else if let top = topMood {
                let tag = MoodTag.all.first { $0.id == top.0 } ?? MoodTag.none
                Text("\(tag.emoji) \(tag.label) — \(top.1) rituals")
                    .font(.subheadline)
                Text("\(events.count) total rituals · \(events.filter { $0.usedSOS }.count) by grace")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func last91Days() -> [Bool] {
        var flags: [Bool] = []
        for offset in (0..<91).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: Date())) else { continue }
            let next = day.addingTimeInterval(86400)
            flags.append(events.contains { $0.timestamp >= day && $0.timestamp < next })
        }
        return flags
    }
}
