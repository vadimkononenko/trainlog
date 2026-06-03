import SwiftUI

struct SignUpView: View {
    @State private var viewModel: SignUpViewModel
    let onSignIn: () -> Void

    init(
        viewModel: SignUpViewModel,
        onSignIn: @escaping () -> Void
    ) {
        self._viewModel = State(initialValue: viewModel)
        self.onSignIn = onSignIn
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

                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
            }

            if case .failed(let message) = viewModel.viewState {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            Button {
                Task {
                    await viewModel.signUp()
                }
            } label: {
                if viewModel.viewState == .submitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Label("Create Account", systemImage: "person.badge.plus")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.viewState == .submitting)

            Button {
                onSignIn()
            } label: {
                Label("Sign In", systemImage: "arrow.left.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Create Account")
    }
}

#Preview {
    let container = DIContainer.preview()

    NavigationStack {
        SignUpView(
            viewModel: SignUpViewModel(
                authSession: container.authSession,
                authRepository: container.authRepository
            ),
            onSignIn: {}
        )
    }
}
