import SwiftUI

struct ExercisesView: View {
    let viewModel: ExercisesViewModel

    var body: some View {
        ContentUnavailableView(
            viewModel.emptyStateTitle,
            systemImage: "figure.strengthtraining.traditional",
            description: Text(viewModel.emptyStateMessage)
        )
        .navigationTitle("Exercises")
    }
}

#Preview {
    NavigationStack {
        ExercisesView(viewModel: ExercisesViewModel())
    }
}
