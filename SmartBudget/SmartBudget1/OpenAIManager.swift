import Foundation

class OpenAIManager {
    static let shared = OpenAIManager()

    private let apiKey = "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"
    func classify(note: String, completion: @escaping (_ amount: Double, _ category: String, _ note: String, _ date: Date) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("❌ 錯誤")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        今天是 \(formattedToday())。
        請從下列文字中提取支出金額、分類、備註與日期，並回傳 JSON 格式。
        日期可以是「今天」、「昨天」、「前天」，或具體日期（YYYY-MM-DD）。
        若使用相對詞（如昨天），請原樣輸出即可，不要轉換為具體日期。
        若未提及日期，預設為「今天」。

        文字：「\(note)」

        回傳格式如下：
        {
          "amount": 數字,
          "category": "分類",
          "note": "簡短備註",
          "date": "今天" 或 "昨天" 或 "前天" 或 "YYYY-MM-DD"
        }
        只輸出 JSON，請不要加任何解釋。
        """

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "temperature": 0.2
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 網路錯誤：\(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ 沒有收到資料")
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                print("❌ GPT 回傳格式錯誤：\(String(data: data, encoding: .utf8) ?? "")")
                return
            }

            if let contentData = content.data(using: .utf8),
               let result = try? JSONSerialization.jsonObject(with: contentData) as? [String: Any],
               let amount = result["amount"] as? Double,
               let category = result["category"] as? String,
               let note = result["note"] as? String,
               let dateText = result["date"] as? String {

                let finalDate = self.resolveDate(from: dateText)

                DispatchQueue.main.async {
                    completion(amount, category, note, finalDate)
                }
            } else {
                print("❌ GPT 回傳 JSON 解碼失敗：\(content)")
            }
        }.resume()
    }

    private func formattedToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func resolveDate(from text: String) -> Date {
        let calendar = Calendar.current
        if text.contains("前天") {
            return calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        } else if text.contains("昨天") {
            return calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        } else if text.contains("今天") {
            return Date()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.date(from: text) ?? Date()
        }
    }
}
