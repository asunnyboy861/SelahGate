import PhotosUI
import SwiftUI

struct BibleCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pickerItem: PhotosPickerItem?
    @State private var status: Status = .idle
    @State private var matchedVerse: Verse?

    enum Status: Equatable {
        case idle, working, matched, notFound, needKey
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer()
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.gold)
                Text("Open your paper Bible, snap a page, and let that verse carry you through.")
                    .font(Theme.serifLarge)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                statusView
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Take or choose a photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.gold)
                .padding(.horizontal, 30)
                if status == .needKey {
                    Text("Paper Bible unlock uses your own API key. Add one in Settings → AI.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .navigationTitle("Paper Bible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onChange(of: pickerItem) {
                guard let item = pickerItem else { return }
                recognize(item)
            }
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch status {
        case .idle:
            EmptyView()
        case .working:
            ProgressView("Reading the page…")
        case .matched:
            if let verse = matchedVerse {
                Components.VerseCard(verse: verse)
                    .padding(.horizontal, 24)
                Button("Amen — add to Vault") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.gold)
            }
        case .notFound:
            Text("That page didn't match a verse we know. Try another shot — no penalty.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        case .needKey:
            EmptyView()
        }
    }

    private func recognize(_ item: PhotosPickerItem) {
        guard let key = AISettings.byoKey else {
            status = .needKey
            return
        }
        status = .working
        Task {
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    status = .notFound
                    return
                }
                let raw = try await PrayerEngine.shared.generateVerseMatch(from: data, key: key)
                if let verse = VerseLibrary.match(text: raw) {
                    matchedVerse = verse
                    status = .matched
                } else {
                    status = .notFound
                }
            } catch {
                status = .notFound
            }
        }
    }
}
