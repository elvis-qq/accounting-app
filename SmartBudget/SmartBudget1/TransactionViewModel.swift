import Foundation

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []

    func addTransaction(amount: Double, category: String, note: String, date: Date) {
        let newTransaction = Transaction(amount: amount, category: category, note: note, date: date)
        transactions.append(newTransaction)
    }

    func deleteTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
    }

    // MARK: - 分析統計

    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var todayAmount: Double {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return transactions
            .filter { $0.date >= startOfToday }
            .reduce(0) { $0 + $1.amount }
    }

    var weeklyAmount: Double {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return 0 }
        return transactions
            .filter { $0.date >= startOfWeek }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyAmount: Double {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start else { return 0 }
        return transactions
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }
}
