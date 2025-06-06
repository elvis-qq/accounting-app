import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var viewModel: TransactionViewModel

    // 分類總和（用於圓餅圖）
    var categoryTotals: [String: Double] {
        Dictionary(grouping: viewModel.transactions, by: { $0.category })
            .mapValues { group in
                group.reduce(0) { $0 + $1.amount }
            }
    }

    // 月份總支出（用於長條圖）
    var monthlyTotals: [(String, Double)] {
        let grouped = Dictionary(grouping: viewModel.transactions) { txn in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            return formatter.string(from: txn.date)
        }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("📊 分類支出占比")
                    .font(.headline)
                    .padding(.leading)

                Chart {
                    ForEach(Array(categoryTotals.keys), id: \.self) { category in
                        if let amount = categoryTotals[category] {
                            SectorMark(
                                angle: .value("Amount", amount),
                                innerRadius: .ratio(0.5),
                                angularInset: 1.0
                            )
                            .foregroundStyle(by: .value("分類", category))
                        }
                    }
                }
                .frame(height: 250)

                Divider()

                Text("📅 每月總支出")
                    .font(.headline)
                    .padding(.leading)

                Chart {
                    ForEach(monthlyTotals, id: \.0) { month, amount in
                        BarMark(
                            x: .value("月份", month),
                            y: .value("支出", amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 250)
            }
            .padding()
        }
        .navigationTitle("統計分析")
    }
}
