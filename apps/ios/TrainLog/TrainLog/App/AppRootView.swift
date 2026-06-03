import SwiftData
import SwiftUI

struct AppRootView: View {
    let coordinator: AppCoordinator

    var body: some View {
        Group {
            switch coordinator.rootFlow {
            case .restoring:
                ProgressView()
            case .auth:
                AuthCoordinatorView(coordinator: coordinator.authCoordinator)
            case .main:
                MainCoordinatorView(coordinator: coordinator.mainCoordinator)
            }
        }
        .task {
            await coordinator.restoreSessionIfNeeded()
        }
    }
}

#Preview {
    let container = DIContainer.preview()

    AppRootView(coordinator: container.appCoordinator)
        .modelContainer(container.modelContainer)
}
