import Foundation

struct Transaction: Identifiable, Hashable {
    var id = UUID()
    var amount: Double
    var category: String
    var note: String
    var date: Date
}
