import SwiftUI
import CoreLocation

@MainActor
final class AppViewModel: ObservableObject {
    @Published var selectedStation: TideStation
    @Published var tideInfo: TideInfo?
    @Published var hourlyWeather: [HourlyWeather] = []
    @Published var dailyForecast: [DailyForecast] = []
    @Published var solunarInfo: SolunarInfo?
    @Published var currentBiteScore: Int = 50
    @Published var isLoading = false
    @Published var selectedDate: Date = Date()

    let locationManager = LocationManager()

    init() {
        self.selectedStation = TideStation.allStations.first(where: { $0.id == "tokyo" })!
    }

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        async let tideTask: () = loadTide()
        async let weatherTask: () = loadWeather()
        loadSolunar()

        await tideTask
        await weatherTask
        calculateCurrentBiteScore()
    }

    func loadTide() async {
        let info = await TideService.shared.fetchTideInfo(station: selectedStation, date: selectedDate)
        self.tideInfo = info
    }

    func loadWeather() async {
        do {
            async let hourly = WeatherService.shared.fetchHourlyWeather(
                latitude: selectedStation.latitude, longitude: selectedStation.longitude)
            async let marine = WeatherService.shared.fetchMarineWeather(
                latitude: selectedStation.latitude, longitude: selectedStation.longitude)
            async let daily = WeatherService.shared.fetchDailyForecast(
                latitude: selectedStation.latitude, longitude: selectedStation.longitude)

            var weather = try await hourly
            let waves = try await marine
            self.dailyForecast = try await daily

            // Merge wave data
            for i in 0..<min(weather.count, waves.count) {
                if let wh = waves[i] {
                    weather[i] = HourlyWeather(
                        time: weather[i].time,
                        temperature: weather[i].temperature,
                        weatherCode: weather[i].weatherCode,
                        windSpeed: weather[i].windSpeed,
                        windDirection: weather[i].windDirection,
                        pressure: weather[i].pressure,
                        humidity: weather[i].humidity,
                        precipitationProbability: weather[i].precipitationProbability,
                        waveHeight: wh
                    )
                }
            }
            self.hourlyWeather = weather
        } catch {
            print("Weather error: \(error)")
        }
    }

    func loadSolunar() {
        solunarInfo = SolunarCalculator.calculate(
            date: selectedDate,
            latitude: selectedStation.latitude,
            longitude: selectedStation.longitude
        )
    }

    func calculateCurrentBiteScore() {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        guard let weather = hourlyWeather.min(by: {
            abs($0.time.timeIntervalSince(now)) < abs($1.time.timeIntervalSince(now))
        }) else { return }

        // Pressure change: compare to 3 hours ago
        let threeHoursAgo = now.addingTimeInterval(-3 * 3600)
        let prevWeather = hourlyWeather.min(by: {
            abs($0.time.timeIntervalSince(threeHoursAgo)) < abs($1.time.timeIntervalSince(threeHoursAgo))
        })
        let pressureChange = prevWeather.map { weather.pressure - $0.pressure } ?? 0

        let moonPhase = SolunarCalculator.moonPhase(for: now)

        currentBiteScore = BiteScoreCalculator.calculate(
            tideHeight: tideInfo?.currentHeight,
            tideRate: nil,
            pressure: weather.pressure,
            pressureChange: pressureChange,
            windSpeed: weather.windSpeed,
            moonPhase: moonPhase,
            weatherCode: weather.weatherCode,
            hour: hour
        )
    }

    func updateStation(from location: CLLocationCoordinate2D) {
        selectedStation = TideStation.nearest(to: location)
    }

    func selectStation(_ station: TideStation) {
        selectedStation = station
        Task { await loadAll() }
    }
}
