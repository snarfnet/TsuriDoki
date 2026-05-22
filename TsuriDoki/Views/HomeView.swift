import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Bite Score Card
                    BiteScoreCard(score: viewModel.currentBiteScore)
                        .padding(.horizontal)

                    // Station & Current Conditions
                    CurrentConditionsCard()
                        .padding(.horizontal)

                    // Tide Mini Chart
                    if let tideInfo = viewModel.tideInfo {
                        TideMiniChart(tideInfo: tideInfo)
                            .padding(.horizontal)
                    }

                    // Solunar
                    if let solunar = viewModel.solunarInfo {
                        SolunarCard(solunar: solunar)
                            .padding(.horizontal)
                    }

                    // Hourly Weather Strip
                    if !viewModel.hourlyWeather.isEmpty {
                        HourlyWeatherStrip(weather: Array(viewModel.hourlyWeather.prefix(24)))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("釣りドキ")
            .refreshable {
                await viewModel.loadAll()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

// MARK: - Bite Score Card

struct BiteScoreCard: View {
    let score: Int

    var scoreColor: Color {
        switch score {
        case 80...100: return .red
        case 60..<80: return .orange
        case 40..<60: return .yellow
        default: return .blue
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("爆釣スコア")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100.0)
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Text(BiteScoreCalculator.scoreLabel(score))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(scoreColor)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Current Conditions

struct CurrentConditionsCard: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        let weather = currentWeather

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(Color("AccentColor"))
                Text(viewModel.selectedStation.name)
                    .font(.headline)
                Spacer()
                if let w = weather {
                    Image(systemName: w.weatherIcon)
                        .font(.title2)
                        .foregroundStyle(.orange)
                    Text(w.weatherDescription)
                        .font(.subheadline)
                }
            }

            if let w = weather {
                HStack(spacing: 20) {
                    ConditionItem(icon: "thermometer.medium", value: String(format: "%.0f°", w.temperature), label: "気温")
                    ConditionItem(icon: "wind", value: String(format: "%.0fm/s", w.windSpeed), label: w.windDirectionText)
                    ConditionItem(icon: "gauge.medium", value: String(format: "%.0f", w.pressure), label: "hPa")
                    if let wave = w.waveHeight {
                        ConditionItem(icon: "water.waves", value: String(format: "%.1fm", wave), label: "波高")
                    }
                }
            }

            if let tide = viewModel.tideInfo {
                HStack(spacing: 20) {
                    ConditionItem(icon: "water.waves.and.arrow.up", value: String(format: "%.1fm", tide.currentHeight), label: "潮位")

                    ForEach(tide.extremes.prefix(4)) { extreme in
                        let timeStr = extreme.time.formatted(.dateTime.hour().minute())
                        ConditionItem(
                            icon: extreme.type == .high ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                            value: timeStr,
                            label: extreme.type.rawValue
                        )
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    var currentWeather: HourlyWeather? {
        let now = Date()
        return viewModel.hourlyWeather.min(by: {
            abs($0.time.timeIntervalSince(now)) < abs($1.time.timeIntervalSince(now))
        })
    }
}

struct ConditionItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Solunar Card

struct SolunarCard: View {
    let solunar: SolunarInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: solunar.moonPhaseIcon)
                    .font(.title2)
                Text(solunar.moonPhaseName)
                    .font(.headline)
                Spacer()
                Text("ソルナー評価: \(solunar.dailyRating)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                if let rise = solunar.sunrise {
                    Label(rise.formatted(.dateTime.hour().minute()), systemImage: "sunrise.fill")
                        .font(.caption)
                }
                if let set = solunar.sunset {
                    Label(set.formatted(.dateTime.hour().minute()), systemImage: "sunset.fill")
                        .font(.caption)
                }
                if let rise = solunar.moonrise {
                    Label(rise.formatted(.dateTime.hour().minute()), systemImage: "moonrise.fill")
                        .font(.caption)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("活性タイム")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(solunar.majorPeriods) { period in
                    HStack {
                        Circle().fill(.red).frame(width: 8, height: 8)
                        Text("メジャー")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Text("\(period.start.formatted(.dateTime.hour().minute())) - \(period.end.formatted(.dateTime.hour().minute()))")
                            .font(.caption)
                    }
                }
                ForEach(solunar.minorPeriods) { period in
                    HStack {
                        Circle().fill(.orange).frame(width: 8, height: 8)
                        Text("マイナー")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Text("\(period.start.formatted(.dateTime.hour().minute())) - \(period.end.formatted(.dateTime.hour().minute()))")
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Hourly Weather Strip

struct HourlyWeatherStrip: View {
    let weather: [HourlyWeather]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("時間ごとの天気")
                .font(.subheadline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(weather) { w in
                        VStack(spacing: 6) {
                            Text(w.time.formatted(.dateTime.hour()))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Image(systemName: w.weatherIcon)
                                .font(.caption)
                            Text(String(format: "%.0f°", w.temperature))
                                .font(.caption)
                                .fontWeight(.semibold)
                            HStack(spacing: 2) {
                                Image(systemName: "wind")
                                    .font(.system(size: 8))
                                Text(String(format: "%.0f", w.windSpeed))
                                    .font(.system(size: 9))
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
