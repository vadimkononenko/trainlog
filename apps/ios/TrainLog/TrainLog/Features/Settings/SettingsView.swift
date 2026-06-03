import SwiftUI

struct SettingsView: View {
    let viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Account") {
                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: SettingsViewModel(authSession: AuthSession()))
    }
}
