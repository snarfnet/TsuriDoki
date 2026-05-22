import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if viewModel.dailyForecast.isEmpty {
                        ContentUnavailableView("読み込み中...", systemImage: "arrow.clockwise")
                            .padding(.top, 60)
                    }

                    ForEach(viewModel.dailyForecast) { day in
                        ForecastDayRow(day: day)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("10日間予報")
            .refreshable {
                await viewModel.loadAll()
            }
        }
    }
}

struct ForecastDayRow: View {
    let day: DailyForecast

    var scoreColor: Color {
        switch day.biteScore {
        case 80...100: return .red
        case 60..<80: return .orange
        case 40..<60: return .yellow
        default: return .blue
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(dayOfWeek)
                    .font(.caption)
                    .foregroundStyle(isWeekend ? .red : .secondary)
                Text(dayNumber)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(width: 40, alignment: .leading)

            // Weather icon
            Image(systemName: day.weatherIcon)
                .font(.title2)
                .frame(width: 30)

            // Temp
            VStack(spacing: 2) {
                Text(String(format: "%.0f°", day.tempMax))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                Text(String(format: "%.0f°", day.tempMin))
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .frame(width: 35)

            // Wind & Rain
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "wind")
                        .font(.system(size: 10))
                    Text(String(format: "%.0fm/s", day.windSpeedMax))
                        .font(.caption)
                }
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.blue)
                    Text("\(day.precipitationProbability)%")
                        .font(.caption)
                }
            }
            .foregroundStyle(.secondary)
            .frame(width: 65, alignment: .leading)

            Spacer()

            // Bite Score
            VStack(spacing: 2) {
                Text("\(day.biteScore)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor)
                Text(BiteScoreCalculator.scoreLabel(day.biteScore))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(scoreColor)
            }
            .frame(width: 55)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter.string(from: day.date)
    }

    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day.date)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: day.date)
        return weekday == 1 || weekday == 7
    }
}
