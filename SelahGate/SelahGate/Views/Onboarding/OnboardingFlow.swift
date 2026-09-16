import SwiftUI
import FamilyControls

struct OnboardingFlow: View {
    let onFinish: () -> Void

    @State private var step = 0
    @State private var distraction: String = "Social"
    @State private var depth: RitualDepth = .light
    @State private var pickerSelection = FamilyActivitySelection()
    @State private var showRitualDemo = false
    @StateObject private var guardModel = GuardModel.shared

    private let distractions = ["Social", "Games", "News", "Shopping", "Videos"]

    var body: some View {
        ZStack {
            Theme.dawn.ignoresSafeArea()
            VStack {
                ProgressView(value: Double(step + 1), total: 8)
                    .tint(Theme.gold)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                TabView(selection: $step) {
                    welcome.tag(0)
                    resonance.tag(1)
                    permission.tag(2)
                    pickerStep.tag(3)
                    depthStep.tag(4)
                    freeTierStep.tag(5)
                    notificationsStep.tag(6)
                    firstRitual.tag(7)
                    finish.tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .fullScreenCover(isPresented: $showRitualDemo) {
                RitualScreen(depth: .light, source: "onboarding") {
                    showRitualDemo = false
                    step = 8
                }
                .interactiveDismissDisabled(true)
            }
        }
    }

    private var stepFooter: some View {
        VStack(spacing: 16) {
            nextButton
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 30)
    }

    private var nextButton: some View {
        Button {
            withAnimation { step += 1 }
        } label: {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.gold)
        .accessibilityLabel("Continue to the next step")
    }

    private var welcome: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "door.left.hand.open")
                .font(.system(size: 60))
                .foregroundStyle(Theme.gold)
            Text("Pray Before You Scroll.")
                .font(Theme.serifTitle)
                .multilineTextAlignment(.center)
            Text("SelahGate turns every distracting unlock into a moment of peace.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            stepFooter
        }
    }

    private var resonance: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("What steals your attention?")
                .font(Theme.serifTitle)
                .multilineTextAlignment(.center)
            VStack(spacing: 10) {
                ForEach(distractions, id: \.self) { item in
                    Button {
                        distraction = item
                        withAnimation { step = 2 }
                    } label: {
                        HStack {
                            Text(item)
                            Spacer()
                            if distraction == item {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.gold)
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Select \(item)")
                }
            }
            Spacer()
            stepFooter
        }
    }

    private var permission: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundStyle(Theme.gold)
            Text("Screen Time permission")
                .font(Theme.serifTitle)
            Text("Used only to guard the apps you pick. Nothing leaves your iPhone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                Task {
                    await guardModel.authorize()
                    withAnimation { step = 3 }
                }
            } label: {
                Text("Grant Access")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .padding(.horizontal, 30)
            Button("Later") { withAnimation { step = 3 } }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 30)
        }
    }

    private var pickerStep: some View {
        VStack(spacing: 12) {
            Text("Guard your \(distraction.lowercased()) apps")
                .font(Theme.serifLarge)
                .padding(.top, 20)
            FamilyActivityPicker(selection: $pickerSelection)
            stepFooter
        }
        .onAppear { pickerSelection = guardModel.selection }
    }

    private var depthStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("How deep is your unlock?")
                .font(Theme.serifTitle)
            Text("Deeper ritual, longer focus window. You can change this anytime.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            VStack(spacing: 12) {
                ForEach(RitualDepth.allCases, id: \.self) { d in
                    Button {
                        depth = d
                        withAnimation { step = 5 }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(d.title) — \(d.subtitle)").font(.headline)
                                Text("\(d.windowMinutes) minute window").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if depth == d {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.gold)
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(d.title) depth, \(d.windowMinutes) minute window")
                }
            }
            .padding(.horizontal, 24)
            Spacer()
            stepFooter
        }
    }

    private var freeTierStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Free, forever.")
                .font(Theme.serifTitle)
            VStack(alignment: .leading, spacing: 10) {
                bullet("Unlimited guarding of your chosen apps")
                bullet("3 prayer ritual unlocks a day")
                bullet("The complete offline verse library")
                bullet("No weekly traps. Cancel anytime.")
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)
            Text("We tell you what's free before any price appears. That's a promise.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            stepFooter
        }
    }

    private var notificationsStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bell.badge")
                .font(.system(size: 44))
                .foregroundStyle(Theme.gold)
            Text("A gentle nudge when your focus window ends.")
                .font(Theme.serifLarge)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                Task {
                    _ = await NotificationHelper.requestAuthorization()
                    withAnimation { step = 7 }
                }
            } label: {
                Text("Allow notifications")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .padding(.horizontal, 30)
            Button("Skip") { withAnimation { step = 7 } }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 30)
        }
    }

    private var firstRitual: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Try it now.")
                .font(Theme.serifTitle)
            Text("Read a verse, swipe Amen. This is exactly how an unlock will feel.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                showRitualDemo = true
            } label: {
                Text("Start my first Selah")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .padding(.horizontal, 30)
            Button("Skip for now") { step = 8 }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 30)
        }
    }

    private var finish: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Day 1 begins. 🕊")
                .font(Theme.serifTitle)
            Text("Your verse collection is waiting in the Vault.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                guardModel.saveSelection(pickerSelection)
                onFinish()
            } label: {
                Text("Enter SelahGate")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.gold)
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.sage)
            Text(text).font(.subheadline)
        }
    }
}
