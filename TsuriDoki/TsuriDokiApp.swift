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
                .onChange(of: viewModel.locationManager.locationUpdateCount) { _, _ in
                    if let loc = viewModel.locationManager.location {
                        viewModel.updateStation(from: loc)
                        Task { await viewModel.loadAll() }
                    }
                }
        }
    }
}
