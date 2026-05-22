import SwiftUI

struct StationPickerView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""

    var filteredStations: [String: [TideStation]] {
        let stations = searchText.isEmpty
            ? TideStation.allStations
            : TideStation.allStations.filter { $0.name.contains(searchText) || $0.prefecture.contains(searchText) }

        return Dictionary(grouping: stations, by: { $0.prefecture })
    }

    var sortedPrefectures: [String] {
        let order = ["北海道", "青森県", "岩手県", "宮城県", "秋田県", "山形県", "福島県",
                     "千葉県", "東京都", "神奈川県", "新潟県", "富山県", "石川県",
                     "静岡県", "愛知県", "三重県", "京都府", "大阪府", "兵庫県", "和歌山県",
                     "鳥取県", "島根県", "広島県", "山口県",
                     "香川県", "徳島県", "高知県", "愛媛県",
                     "福岡県", "長崎県", "熊本県", "大分県", "宮崎県", "鹿児島県", "沖縄県"]
        return filteredStations.keys.sorted { a, b in
            (order.firstIndex(of: a) ?? 99) < (order.firstIndex(of: b) ?? 99)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Current location
                Section {
                    Button {
                        viewModel.locationManager.requestLocation()
                    } label: {
                        Label("現在地から自動検出", systemImage: "location.fill")
                    }
                }

                // Station list
                ForEach(sortedPrefectures, id: \.self) { prefecture in
                    Section(prefecture) {
                        ForEach(filteredStations[prefecture] ?? []) { station in
                            Button {
                                viewModel.selectStation(station)
                            } label: {
                                HStack {
                                    Text(station.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if station.id == viewModel.selectedStation.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color("AccentColor"))
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "地点名・県名で検索")
            .navigationTitle("観測地点")
        }
    }
}
