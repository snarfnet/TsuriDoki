import SwiftUI

@main
struct TsuriDokiApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(viewModel)
                .task {
                    viewModel.locationManager.requestPermission()
                    await viewModel.loadAll()
                }
                .onChange(of: viewModel.locationManager.location) { _, newLoc in
                    if let loc = newLoc {
                        viewModel.updateStation(from: loc)
                        Task { await viewModel.loadAll() }
                    }
                }
        }
    }
}
