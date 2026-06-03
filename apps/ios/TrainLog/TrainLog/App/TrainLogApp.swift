import SwiftData
import SwiftUI

@main
struct TrainLogApp: App {
    private let container: DIContainer

    init() {
        container = DIContainer.live()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(coordinator: container.appCoordinator)
                .modelContainer(container.modelContainer)
        }
    }
}
