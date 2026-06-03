import SwiftUI

struct AuthView: View {
    @State private var viewModel: AuthViewModel

    init(viewModel: AuthViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            VStack(spacing: 12) {
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
            }

            Button {
                viewModel.continueWithPlaceholderSession()
            } label: {
                Label("Continue", systemImage: "arrow.right.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthView(viewModel: AuthViewModel(authSession: AuthSession()))
    }
}
