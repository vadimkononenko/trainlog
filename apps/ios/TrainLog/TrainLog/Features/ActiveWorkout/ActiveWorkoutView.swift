import SwiftUI

struct ActiveWorkoutView: View {
    let viewModel: ActiveWorkoutViewModel

    var body: some View {
        ContentUnavailableView(
            viewModel.emptyStateTitle,
            systemImage: "play.circle.fill",
            description: Text(viewModel.emptyStateMessage)
        )
        .navigationTitle("Workout")
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(viewModel: ActiveWorkoutViewModel())
    }
}
