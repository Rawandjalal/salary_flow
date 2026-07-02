import WidgetKit
import SwiftUI

// Struct representing the widget data, shared via AppGroups/UserDefaults
struct SalaryFlowWidgetEntry: TimelineEntry {
    let date: Date
    let dailyBudgetLeft: Double
    let mainCurrency: String
    let runwayForecastDays: Int
    let todaysSpent: Double
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SalaryFlowWidgetEntry {
        SalaryFlowWidgetEntry(
            date: Date(),
            dailyBudgetLeft: 45.0,
            mainCurrency: "USD",
            runwayForecastDays: 14,
            todaysSpent: 12.50
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SalaryFlowWidgetEntry) -> ()) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.rawandjalal.salaryflow")
        let budget = sharedDefaults?.double(forKey: "dailyBudgetLeft") ?? 45.0
        let currency = sharedDefaults?.string(forKey: "mainCurrency") ?? "USD"
        let runway = sharedDefaults?.integer(forKey: "runwayForecastDays") ?? 14
        let spent = sharedDefaults?.double(forKey: "todaysSpent") ?? 12.50
        
        let entry = SalaryFlowWidgetEntry(
            date: Date(),
            dailyBudgetLeft: budget,
            mainCurrency: currency,
            runwayForecastDays: runway,
            todaysSpent: spent
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

// SwiftUI view rendering the widget interface (Medium size)
struct SalaryFlowWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Elegant premium dark blue background gradient matching SalaryFlow theme
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.09, green: 0.11, blue: 0.18), Color(red: 0.04, green: 0.05, blue: 0.09)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(alignment: .leading, spacing: 6) {
                // Header row
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .font(.system(size: 14))
                    Text("SalaryFlow")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("Live Widget")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(red: 0.06, green: 0.73, blue: 0.51).opacity(0.12))
                        .cornerRadius(4)
                }
                
                Spacer()
                
                // Bottom content row
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DAILY BUDGET LEFT")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                        
                        let symbol = entry.mainCurrency == "USD" ? "$" : "د.ع"
                        Text("\(String(format: "%.0f", entry.dailyBudgetLeft)) \(symbol)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        
                        Text(entry.runwayForecastDays >= 999 
                             ? "Runway: Infinite" 
                             : "Runway: \(entry.runwayForecastDays) Days")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(red: 0.06, green: 0.73, blue: 0.51))
                    }
                    
                    Spacer()
                    
                    // Quick Action Buttons (deep links into the Flutter app)
                    HStack(spacing: 8) {
                        Link(destination: URL(string: "salaryflow://quick-add?amount=20")!) {
                            WidgetActionButton(label: "+$20", color: Color(red: 0.06, green: 0.73, blue: 0.51))
                        }
                        
                        Link(destination: URL(string: "salaryflow://quick-add?amount=50")!) {
                            WidgetActionButton(label: "+$50", color: Color(red: 0.06, green: 0.73, blue: 0.51))
                        }
                        
                        Link(destination: URL(string: "salaryflow://quick-sub?amount=10")!) {
                            WidgetActionButton(label: "-$10", color: Color(red: 0.94, green: 0.27, blue: 0.27))
                        }
                    }
                }
            }
            .padding(14)
        }
    }
}

struct WidgetActionButton: View {
    let label: String
    let color: Color
    
    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .black))
            .foregroundColor(color)
            .frame(width: 44, height: 36)
            .background(color.opacity(0.12))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }
}

@main
struct SalaryFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        SalaryFlowWidget()
    }
}

struct SalaryFlowWidget: Widget {
    let kind: String = "SalaryFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SalaryFlowWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SalaryFlow Budget Tracker")
        .description("Track your remaining daily budget and log fast cash flows.")
        .supportedFamilies([.systemMedium])
    }
}
