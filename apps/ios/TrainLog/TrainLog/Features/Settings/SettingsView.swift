import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Account") {
                Button(role: .destructive) {
                    Task {
                        await viewModel.signOut()
                    }
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .disabled(viewModel.isSigningOut)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    let container = DIContainer.preview()

    NavigationStack {
        SettingsView(
            viewModel: SettingsViewModel(
                authSession: container.authSession,
                authRepository: container.authRepository
            )
        )
    }
}
