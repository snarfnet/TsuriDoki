import SwiftUI

struct TideMiniChart: View {
    let tideInfo: TideInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("潮汐グラフ")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(tideInfo.stationName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let points = tideInfo.hourlyHeights
                guard let minH = points.map(\.height).min(),
                      let maxH = points.map(\.height).max(),
                      maxH > minH else { return AnyView(EmptyView()) }

                let range = maxH - minH

                return AnyView(
                    ZStack {
                        // Current time indicator
                        let now = Date()
                        let dayStart = Calendar.current.startOfDay(for: tideInfo.date)
                        let progress = now.timeIntervalSince(dayStart) / 86400
                        if progress >= 0 && progress <= 1 {
                            Rectangle()
                                .fill(Color.red.opacity(0.5))
                                .frame(width: 1.5)
                                .position(x: CGFloat(progress) * w, y: h / 2)
                        }

                        // Tide curve
                        Path { path in
                            for (i, point) in points.enumerated() {
                                let x = w * CGFloat(i) / CGFloat(points.count - 1)
                                let y = h - (CGFloat(point.height - minH) / CGFloat(range)) * h * 0.85 - h * 0.075
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(Color("AccentColor"), lineWidth: 2.5)

                        // Fill under curve
                        Path { path in
                            for (i, point) in points.enumerated() {
                                let x = w * CGFloat(i) / CGFloat(points.count - 1)
                                let y = h - (CGFloat(point.height - minH) / CGFloat(range)) * h * 0.85 - h * 0.075
                                if i == 0 { path.move(to: CGPoint(x: x, y: h)) }
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                            path.addLine(to: CGPoint(x: w, y: h))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Color("AccentColor").opacity(0.3), Color("AccentColor").opacity(0.05)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )

                        // High/Low labels
                        ForEach(tideInfo.extremes) { extreme in
                            let dayStartInterval = Calendar.current.startOfDay(for: tideInfo.date).timeIntervalSinceReferenceDate
                            let xProgress = (extreme.time.timeIntervalSinceReferenceDate - dayStartInterval) / 86400
                            if xProgress >= 0 && xProgress <= 1 {
                                let x = CGFloat(xProgress) * w
                                let y = h - (CGFloat(extreme.height - minH) / CGFloat(range)) * h * 0.85 - h * 0.075

                                VStack(spacing: 1) {
                                    Text(extreme.type == .high ? "満" : "干")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(extreme.type == .high ? .blue : .orange)
                                    Text(extreme.time.formatted(.dateTime.hour().minute()))
                                        .font(.system(size: 8))
                                        .foregroundStyle(.secondary)
                                }
                                .position(x: x, y: extreme.type == .high ? y - 18 : y + 18)
                            }
                        }

                        // Time axis labels
                        ForEach([0, 6, 12, 18, 24], id: \.self) { hour in
                            Text("\(hour)")
                                .font(.system(size: 9))
                                .foregroundStyle(.tertiary)
                                .position(x: CGFloat(hour) / 24.0 * w, y: h + 10)
                        }
                    }
                )
            }
            .frame(height: 140)
            .padding(.bottom, 12)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
