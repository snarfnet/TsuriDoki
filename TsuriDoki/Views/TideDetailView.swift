import SwiftUI

struct TideDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Date picker
                    DatePicker("日付", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .onChange(of: viewModel.selectedDate) { _, _ in
                            Task {
                                await viewModel.loadTide()
                                viewModel.loadSolunar()
                            }
                        }

                    if let tideInfo = viewModel.tideInfo {
                        // Large tide chart
                        TideMiniChart(tideInfo: tideInfo)
                            .padding(.horizontal)

                        // Extremes table
                        VStack(alignment: .leading, spacing: 8) {
                            Text("満潮・干潮")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            ForEach(tideInfo.extremes) { extreme in
                                HStack {
                                    Image(systemName: extreme.type == .high ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                        .foregroundStyle(extreme.type == .high ? .blue : .orange)
                                    Text(extreme.type.rawValue)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text(extreme.time.formatted(.dateTime.hour().minute()))
                                        .font(.subheadline)
                                    Text(String(format: "%.2fm", extreme.height))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 50, alignment: .trailing)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)

                        // Hourly heights table
                        VStack(alignment: .leading, spacing: 8) {
                            Text("時間ごとの潮位")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                                ForEach(tideInfo.hourlyHeights) { point in
                                    VStack(spacing: 2) {
                                        Text(point.time.formatted(.dateTime.hour()))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                        Text(String(format: "%.1f", point.height))
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 4)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                    }

                    // Solunar
                    if let solunar = viewModel.solunarInfo {
                        SolunarCard(solunar: solunar)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("潮汐詳細")
        }
    }
}
