import WidgetKit
import SwiftUI

// MARK: - App Group Key
private let kAppGroup = "group.com.example.salaryFlow"

// MARK: - Entry Model
struct BalanceEntry: TimelineEntry {
    let date: Date
    let balanceUsd: Double
    let balanceIqd: Double
    let dailyBudgetUsd: Double
    let dailyBudgetIqd: Double
    let runwayDays: Int
    let lastTransaction: String
}

// MARK: - Preview Data
extension BalanceEntry {
    static var placeholder: BalanceEntry {
        BalanceEntry(
            date: Date(),
            balanceUsd: 1_250.00,
            balanceIqd: 1_635_000,
            dailyBudgetUsd: 48.50,
            dailyBudgetIqd: 63_525,
            runwayDays: 25,
            lastTransaction: "Groceries  -$12.50"
        )
    }
}

// MARK: - Timeline Provider
struct BalanceProvider: TimelineProvider {

    func placeholder(in context: Context) -> BalanceEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> Void) {
        let entry = readEntry()
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func readEntry() -> BalanceEntry {
        let d = UserDefaults(suiteName: kAppGroup)
        let balUsd = d?.double(forKey: "balance_usd") ?? 0
        let balIqd = d?.double(forKey: "balance_iqd") ?? 0
        let budUsd = d?.double(forKey: "daily_budget_usd") ?? 0
        let budIqd = d?.double(forKey: "daily_budget_iqd") ?? 0
        let runway = d?.integer(forKey: "runway_days") ?? 0
        let lastTx = d?.string(forKey: "last_transaction") ?? "—"
        return BalanceEntry(
            date: Date(),
            balanceUsd: balUsd,
            balanceIqd: balIqd,
            dailyBudgetUsd: budUsd,
            dailyBudgetIqd: budIqd,
            runwayDays: runway,
            lastTransaction: lastTx
        )
    }
}

// MARK: - Design Tokens
private extension Color {
    static let sfGreen    = Color(red: 0.063, green: 0.725, blue: 0.506)   // #10B981
    static let sfPurple   = Color(red: 0.482, green: 0.259, blue: 0.875)   // #7B42DF
    static let sfBg       = Color(red: 0.027, green: 0.020, blue: 0.063)   // #070514
    static let sfSurface  = Color(red: 0.067, green: 0.047, blue: 0.118)   // #110C1E
    static let sfBorder   = Color.white.opacity(0.08)
    static let sfText     = Color.white
    static let sfSubtext  = Color.white.opacity(0.45)
}

private func fmtUsd(_ v: Double) -> String {
    "$\(String(format: v >= 1000 ? "%.0f" : "%.2f", v))"
}

private func fmtIqd(_ v: Double) -> String {
    v >= 1_000_000
        ? "\(String(format: "%.1f", v / 1_000_000))M IQD"
        : "\(Int(v / 1_000))K IQD"
}

// MARK: - Small Widget (Home Screen)
struct SmallView: View {
    let entry: BalanceEntry
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.sfBg)
            // Subtle glow
            Circle()
                .fill(Color.sfGreen.opacity(0.12))
                .frame(width: 80, height: 80)
                .offset(x: 40, y: -30)
                .blur(radius: 20)
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.sfGreen)
                    Text("SalaryFlow")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.sfSubtext)
                }
                Spacer()
                // Balance
                Text(fmtUsd(entry.balanceUsd))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.sfText)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("Balance")
                    .font(.system(size: 9))
                    .foregroundColor(.sfSubtext)
                Spacer()
                // Footer stats
                HStack(spacing: 8) {
                    Label("\(entry.runwayDays)d", systemImage: "clock.fill")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.sfGreen)
                    Spacer()
                }
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.3))
                    Text(fmtUsd(entry.dailyBudgetUsd) + "/day")
                        .font(.system(size: 8))
                        .foregroundColor(.sfSubtext)
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget (Home Screen)
struct MediumView: View {
    let entry: BalanceEntry
    var body: some View {
        ZStack {
            ContainerRelativeShape().fill(Color.sfBg)
            // Glow
            Ellipse()
                .fill(Color.sfGreen.opacity(0.08))
                .frame(width: 140, height: 100)
                .offset(x: 110, y: -20)
                .blur(radius: 25)
            HStack(spacing: 0) {
                // Left – Main balance
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.sfGreen)
                        Text("SalaryFlow")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.sfSubtext)
                    }
                    Spacer()
                    Text(fmtUsd(entry.balanceUsd))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.sfText)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(fmtIqd(entry.balanceIqd))
                        .font(.system(size: 10))
                        .foregroundColor(.sfSubtext)
                    Spacer()
                    Text(entry.lastTransaction)
                        .font(.system(size: 9))
                        .foregroundColor(.sfSubtext)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.leading, 14)
                .frame(maxWidth: .infinity, alignment: .leading)

                // Separator
                Rectangle()
                    .fill(Color.sfBorder)
                    .frame(width: 0.5)
                    .padding(.vertical, 14)

                // Right – Daily stats
                VStack(spacing: 10) {
                    StatPill(label: "Daily left", value: fmtUsd(entry.dailyBudgetUsd), accent: .sfGreen)
                    StatPill(label: "Runway", value: "\(entry.runwayDays) days",
                             accent: entry.runwayDays >= 14 ? .sfGreen : .orange)
                    StatPill(label: "IQD Daily", value: "\(Int(entry.dailyBudgetIqd / 1000))K",
                             accent: .sfSubtext)
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 12)
            }
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let accent: Color
    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.sfSubtext)
        }
    }
}

// MARK: - Lock Screen: Circular (iOS 16+)
@available(iOS 16.0, *)
struct CircularLockView: View {
    let entry: BalanceEntry
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.sfGreen)
                Text("$\(Int(entry.balanceUsd))")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Lock Screen: Rectangular (iOS 16+)
@available(iOS 16.0, *)
struct RectangularLockView: View {
    let entry: BalanceEntry
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.sfGreen)
            VStack(alignment: .leading, spacing: 1) {
                Text(fmtUsd(entry.balanceUsd))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text("Daily: \(fmtUsd(entry.dailyBudgetUsd))  ·  \(entry.runwayDays)d runway")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Lock Screen: Inline (iOS 16+)
@available(iOS 16.0, *)
struct InlineLockView: View {
    let entry: BalanceEntry
    var body: some View {
        Label(
            "\(fmtUsd(entry.balanceUsd))  ·  \(entry.runwayDays)d",
            systemImage: "chart.line.uptrend.xyaxis"
        )
    }
}

// MARK: - Entry View (dispatch)
struct SalaryFlowWidgetEntryView: View {
    let entry: BalanceEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if #available(iOS 16.0, *) {
            switch family {
            case .systemSmall:            SmallView(entry: entry)
            case .systemMedium:           MediumView(entry: entry)
            case .accessoryCircular:      CircularLockView(entry: entry)
            case .accessoryRectangular:   RectangularLockView(entry: entry)
            case .accessoryInline:        InlineLockView(entry: entry)
            default:                      SmallView(entry: entry)
            }
        } else {
            switch family {
            case .systemSmall:  SmallView(entry: entry)
            case .systemMedium: MediumView(entry: entry)
            default:            SmallView(entry: entry)
            }
        }
    }
}

// MARK: - Widget Configuration
@main
struct SalaryFlowWidget: Widget {
    let kind = "SalaryFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BalanceProvider()) { entry in
            SalaryFlowWidgetEntryView(entry: entry)
                .containerBackground(Color.sfBg, for: .widget)
        }
        .configurationDisplayName("SalaryFlow")
        .description("Balance, daily budget & runway at a glance.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOS 16.0, *) {
            return [
                .systemSmall, .systemMedium,
                .accessoryCircular, .accessoryRectangular, .accessoryInline
            ]
        }
        return [.systemSmall, .systemMedium]
    }
}
