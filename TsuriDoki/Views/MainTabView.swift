import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "fish.fill")
                }

            TideDetailView()
                .tabItem {
                    Label("潮汐", systemImage: "water.waves")
                }

            ForecastView()
                .tabItem {
                    Label("予報", systemImage: "calendar")
                }

            StationPickerView()
                .tabItem {
                    Label("地点", systemImage: "mappin.and.ellipse")
                }
        }
        .tint(Color("AccentColor"))
    }
}
