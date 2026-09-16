import SwiftUI

struct Components {

    struct VerseCard: View {
        let verse: Verse

        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.gold)
                    .frame(width: 4)
                VStack(alignment: .leading, spacing: 12) {
                    Text("\"\(verse.text)\"")
                        .font(Theme.serifVerse)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("— \(verse.ref) · \(verse.translation)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.leading, 16)
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Verse \(verse.ref): \(verse.text)")
        }
    }

    struct QuotaRing: View {
        let used: Int
        let total: Int
        let isPro: Bool

        var body: some View {
            HStack(spacing: 10) {
                if isPro {
                    Label("Pro · Unlimited", systemImage: "infinity")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Theme.gold)
                } else {
                    ForEach(0..<total, id: \.self) { i in
                        Circle()
                            .fill(i < total - used ? Theme.gold : Color.secondary.opacity(0.2))
                            .frame(width: 12, height: 12)
                    }
                    Text("\(max(0, total - used)) left today")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(isPro ? "Pro, unlimited unlocks" : "\(max(0, total - used)) of \(total) free unlocks left today")
        }
    }

    struct StreakGrid: View {
        let days: [Bool]
        let columns: Int

        var body: some View {
            let cols = Array(repeating: GridItem(.flexible(), spacing: 3), count: columns)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyVGrid(columns: cols, spacing: 3) {
                    ForEach(days.indices, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(cellColor(filled: days[i], isLast: i == days.count - 1))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .accessibilityLabel("Prayer heatmap for the last \(days.count) days")
        }

        private func cellColor(filled: Bool, isLast: Bool) -> Color {
            if isLast && !filled {
                return Theme.gold.opacity(0.35)
            }
            return filled ? Theme.gold : Theme.gold.opacity(0.12)
        }
    }

    struct AmenBurst: View {
        @State private var animate = false

        var body: some View {
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Theme.gold.opacity(0.55), Theme.gold.opacity(0)], center: .center, startRadius: 10, endRadius: 160))
                    .scaleEffect(animate ? 1.6 : 0.6)
                    .opacity(animate ? 0 : 0.9)
                VStack(spacing: 10) {
                    Image(systemName: "door.left.open")
                        .font(.system(size: 44))
                        .foregroundStyle(Theme.gold)
                    Text("Go with peace 🕊")
                        .font(Theme.serifLarge)
                        .foregroundStyle(.primary)
                }
                .scaleEffect(animate ? 1 : 0.9)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.1)) {
                    animate = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}
