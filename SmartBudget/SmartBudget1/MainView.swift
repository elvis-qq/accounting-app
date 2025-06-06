import SwiftUI

struct MainView: View {
    @StateObject var viewModel = TransactionViewModel()
    @State private var showingAddView = false

    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 12) {
                    summaryCard(title: "本月支出", amount: viewModel.monthlyAmount, color: .blue)
                    summaryCard(title: "本週支出", amount: viewModel.weeklyAmount, color: .orange)
                    summaryCard(title: "今日支出", amount: viewModel.todayAmount, color: .red)
                }
                .padding(.horizontal)
                .padding(.top)

                List {
                    ForEach(viewModel.transactions) { transaction in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.category)
                                .font(.headline)
                            Text(transaction.note)
                                .foregroundColor(.gray)
                            Text(transaction.date, style: .date)
                                .font(.caption)
                            Text(String(format: "$%.2f", transaction.amount))
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: viewModel.deleteTransaction)
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: {
                        showingAddView = true
                    }) {
                        Text("新增記帳")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle("智慧記帳")
            .navigationBarItems(trailing:
                NavigationLink(destination: StatsView(viewModel: viewModel)) {
                    Image(systemName: "chart.pie.fill")
                        .imageScale(.large)
                        .foregroundColor(.blue)
                }
            )
        }
        .sheet(isPresented: $showingAddView) {
            AddTransactionView(viewModel: viewModel)
        }
    }

    // 卡片樣式顯示摘要
    func summaryCard(title: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(String(format: "$%.0f", amount))
                .font(.headline)
                .bold()
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
