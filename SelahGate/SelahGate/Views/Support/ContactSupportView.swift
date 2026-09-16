import SwiftUI

struct ContactSupportView: View {
    enum Subject: String, CaseIterable, Identifiable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case usage = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .general: return "bubble.left.fill"
            case .feature: return "lightbulb.fill"
            case .bug: return "ant.fill"
            case .usage: return "questionmark.circle.fill"
            case .performance: return "gauge.with.dots.needle.67percent"
            case .ui: return "paintpalette.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    @State private var subject: Subject = .general
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var feedbackStatus: FeedbackStatus?

    private enum FeedbackStatus {
        case success
        case error(String)
    }

    private var emailValid: Bool {
        email.contains("@") && email.contains(".") && email.count > 4
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && emailValid
            && !(subject == .other && customSubject.trimmingCharacters(in: .whitespaces).isEmpty)
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
            && !isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                subjectGrid
                if subject == .other {
                    TextField("Custom subject", text: $customSubject)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Custom subject")
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name").font(.subheadline.weight(.medium))
                    TextField("Your name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Your name")
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").font(.subheadline.weight(.medium))
                    TextField("yourname@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Your email address")
                    if !email.isEmpty && !emailValid {
                        Text("Please enter a valid email address.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Message").font(.subheadline.weight(.medium))
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .overlay(alignment: .topLeading) {
                            if message.isEmpty {
                                Text("Tell us what's on your mind...")
                                    .foregroundStyle(.tertiary)
                                    .padding(8)
                                    .allowsHitTesting(false)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.25))
                        )
                        .accessibilityLabel("Your feedback message")
                    Text("\(message.count) / 1000")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                submitButton
                if let status = feedbackStatus {
                    statusBanner(status)
                }
                Text("We only use your email to respond to this feedback.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(20)
        }
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
        .background(Theme.porcelain)
        .navigationTitle("Contact Support")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: message) {
            if message.count > 1000 {
                message = String(message.prefix(1000))
            }
        }
    }

    private var subjectGrid: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("What's this about?").font(.subheadline.weight(.medium))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(Subject.allCases) { option in
                    subjectTile(option)
                }
            }
        }
    }

    private func subjectTile(_ option: Subject) -> some View {
        let isSelected = subject == option
        return Button {
            subject = option
        } label: {
            VStack(spacing: 6) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : option.icon)
                    .font(.title3)
                Text(option.rawValue)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Theme.gold.opacity(0.18) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.gold : Color.secondary.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Subject: \(option.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var submitButton: some View {
        Button {
            submit()
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Submit").fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.gold)
        .disabled(!canSubmit)
        .accessibilityLabel("Submit feedback")
    }

    private func statusBanner(_ status: FeedbackStatus) -> some View {
        HStack(spacing: 8) {
            switch status {
            case .success:
                Image(systemName: "checkmark.circle.fill").foregroundStyle(Theme.sage)
                Text("Thank you! Your feedback has been sent.")
            case .error(let detail):
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(detail)
            }
        }
        .font(.subheadline)
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }

    private func submit() {
        isSubmitting = true
        feedbackStatus = nil
        let finalSubject = subject == .other ? customSubject : subject.rawValue
        let payload: [String: Any] = [
            "name": name,
            "email": email,
            "subject": finalSubject,
            "message": message,
            "app_name": "SelahGate"
        ]
        guard let url = URL(string: "https://feedback-board.iocompile67692.workers.dev/api/feedback") else {
            isSubmitting = false
            feedbackStatus = .error("Something went wrong. Please try again.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 20
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode), error == nil {
                    feedbackStatus = .success
                    name = ""
                    email = ""
                    message = ""
                    customSubject = ""
                    subject = .general
                } else {
                    feedbackStatus = .error("Something went wrong. Please try again.")
                }
            }
        }.resume()
    }
}
