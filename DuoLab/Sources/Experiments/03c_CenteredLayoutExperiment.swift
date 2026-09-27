import SwiftUI

/// Experiment 03-c: a typical centered, non-scrolling screen (sign-in form) in regular width.
/// In the book posture the center of the screen is the fold (S3 16:34 "audit your app's centered layouts").
///   centerAsIs  → width-limited block centered on screen (ordinary design)
///   centerSplit → two-column layout with ArrangementView(.split.axes(.horizontal)); narrow → form only
///   centerMove  → the same block as the primary of an overlay ArrangementView (moves off the fold)
struct CenteredLayoutExperiment: View {
    var variant: String

    var body: some View {
        Group {
            switch variant {
            case "centerSplit":
                ArrangementView {
                    SignInForm().frame(maxWidth: 400).measured("form")
                } secondary: {
                    Illustration().measured("illustration")
                }
                .arrangementViewStyle(.split.axes(.horizontal))
            case "centerMove":
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    ArrangementView {
                        SignInForm().frame(maxWidth: 400).measured("form")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } secondary: {
                        Color.clear.allowsHitTesting(false)
                    }
                    .arrangementViewStyle(.overlay)
                }
            default:
                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    SignInForm().frame(maxWidth: 400).measured("form")
                }
            }
        }
        .navigationTitle("03-c \(variant)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SignInForm: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 56)).foregroundStyle(.tint)
            Text("Welcome back").font(.title.bold())
            Text("Sign in to continue").foregroundStyle(.secondary)
            TextField("Email", text: $email).textFieldStyle(.roundedBorder)
            SecureField("Password", text: $password).textFieldStyle(.roundedBorder)
            Button("Sign in") {}
                .buttonStyle(.borderedProminent).controlSize(.large)
                .frame(maxWidth: .infinity)
            Button("Forgot password?") {}.font(.footnote)
        }
        .padding(24)
    }
}

private struct Illustration: View {
    var body: some View {
        LinearGradient(colors: [.indigo, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "sparkles").font(.system(size: 64))
                    Text("Illustration / onboarding copy").font(.headline)
                }
                .foregroundStyle(.white)
            }
    }
}
