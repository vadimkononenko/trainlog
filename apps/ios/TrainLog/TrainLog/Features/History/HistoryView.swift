import SwiftUI

struct HistoryView: View {
    let viewModel: HistoryViewModel

    var body: some View {
        ContentUnavailableView(
            viewModel.emptyStateTitle,
            systemImage: "clock.arrow.circlepath",
            description: Text(viewModel.emptyStateMessage)
        )
        .navigationTitle("History")
    }
}

#Preview {
    NavigationStack {
        HistoryView(viewModel: HistoryViewModel())
    }
}
