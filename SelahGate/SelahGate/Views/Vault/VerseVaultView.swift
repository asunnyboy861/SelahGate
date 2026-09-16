import SwiftUI
import SwiftData

struct VerseVaultView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \VerseVaultEntry.firstMet, order: .reverse) private var entries: [VerseVaultEntry]
    @State private var showBibleCamera = false
    @State private var shareImage: UIImage?

    private var dueEntries: [VerseVaultEntry] {
        entries.filter { $0.nextReview <= Date() }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if !dueEntries.isEmpty {
                        reviewCard
                    }
                    collectionCard
                    Button {
                        showBibleCamera = true
                    } label: {
                        Label("Unlock with my paper Bible", systemImage: "camera.viewfinder")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                    .tint(.brown)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .background(Theme.porcelain)
            .navigationTitle("Verse Vault")
            .sheet(isPresented: $showBibleCamera) {
                BibleCameraView()
            }
            .sheet(item: Binding(
                get: { shareImage.map { ShareBox(image: $0) } },
                set: { shareImage = $0?.image }
            )) { box in
                ShareSheet(items: [box.image])
            }
        }
    }

    private struct ShareBox: Identifiable {
        let id = UUID()
        let image: UIImage
    }

    private var reviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Due for review", systemImage: "arrow.clockwise.circle.fill")
                .font(.headline)
                .foregroundStyle(Theme.sage)
            ForEach(dueEntries.prefix(3)) { entry in
                if let verse = VerseLibrary.verse(byRef: entry.verseRef) {
                    SRSReviewCard(entry: entry, verse: verse)
                }
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var collectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Collection", systemImage: "books.vertical.fill")
                    .font(.headline)
                Spacer()
                Text("\(entries.count) verses")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if entries.isEmpty {
                Text("Every verse that unlocks your apps is kept here. Your first one is one ritual away.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                    ForEach(entries.prefix(30)) { entry in
                        VStack(spacing: 4) {
                            Image(systemName: entry.mastered ? "seal.fill" : "bookmark.fill")
                                .foregroundStyle(entry.mastered ? Theme.gold : Theme.sage)
                            Text(entry.verseRef)
                                .font(.caption2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Verse \(entry.verseRef), \(entry.mastered ? "mastered" : "learning")")
                    }
                }
                Button {
                    shareMonthlyCard()
                } label: {
                    Label("Share this month in prayer", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.brown)
            }
        }
        .padding(18)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private func shareMonthlyCard() {
        let renderer = ImageRenderer(content: monthlyCard)
        renderer.scale = 2
        if let image = renderer.uiImage {
            shareImage = image
        }
    }

    private var monthlyCard: some View {
        VStack(spacing: 16) {
            Text("This month in prayer")
                .font(Theme.serifTitle)
            Text("\(entries.count) verses gathered")
                .font(.title3)
            Text("\(entries.filter { $0.mastered }.count) verses mastered")
                .font(.title3)
            Text("SelahGate — Pray Before You Scroll")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(40)
        .background(Theme.dawn)
    }
}

struct SRSReviewCard: View {
    let entry: VerseVaultEntry
    let verse: Verse
    @Environment(\.modelContext) private var modelContext
    @State private var revealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.verseRef)
                .font(.headline)
            if revealed {
                Text(verse.text)
                    .font(Theme.serifVerse)
            } else {
                Button("Recall it, then reveal") { revealed = true }
                    .buttonStyle(.bordered)
                    .tint(.brown)
            }
            if revealed {
                HStack(spacing: 8) {
                    Button("Forgot") { rate(1) }
                        .buttonStyle(.bordered)
                    Button("Got it") { rate(4) }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.gold)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private func rate(_ quality: Int) {
        let result = SRS.next(easiness: entry.easiness, interval: entry.interval, reps: entry.reviewCount, quality: quality)
        entry.easiness = result.easiness
        entry.interval = result.interval
        entry.reviewCount = result.reps
        entry.nextReview = result.due
        entry.mastered = result.interval >= 21
        try? modelContext.save()
        revealed = false
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
