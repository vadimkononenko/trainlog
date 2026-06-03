import SwiftUI

struct SignInView: View {
    @State private var viewModel: SignInViewModel
    let onSignUp: () -> Void

    init(
        viewModel: SignInViewModel,
        onSignUp: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onSignUp = onSignUp
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

            if case .failed(let message) = viewModel.viewState {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                if viewModel.viewState == .submitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Sign In", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit)

            Button {
                onSignUp()
            } label: {
                Label("Create Account", systemImage: "person.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Sign In")
    }
}

#Preview {
    let container = DIContainer.preview()

    NavigationStack {
        SignInView(
            viewModel: SignInViewModel(
                authSession: container.authSession,
                authRepository: container.authRepository
            ),
            onSignUp: {}
        )
    }
}
