import SwiftUI

struct WorkoutTemplatesView: View {
    let viewModel: WorkoutTemplatesViewModel

    var body: some View {
        ContentUnavailableView(
            viewModel.emptyStateTitle,
            systemImage: "list.clipboard",
            description: Text(viewModel.emptyStateMessage)
        )
        .navigationTitle("Templates")
    }
}

#Preview {
    NavigationStack {
        WorkoutTemplatesView(viewModel: WorkoutTemplatesViewModel())
    }
}
