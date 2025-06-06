import SwiftUI

struct VoiceRecordView: View {
    @ObservedObject var viewModel: TransactionViewModel
    @StateObject private var speech = SpeechRecognizer()
    @State private var isRecording = false
    @State private var statusMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("語音記帳")
                .font(.largeTitle)
                .bold()

            Text(speech.transcript)
                .padding()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .border(Color.gray)
                .background(Color(.systemGray6))
                .cornerRadius(8)

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .foregroundColor(.green)
                    .font(.subheadline)
            }

            Button(action: {
                isRecording.toggle()
                statusMessage = ""
                if isRecording {
                    speech.startTranscribing()
                } else {
                    speech.stopTranscribing()
                    processSpeech(text: speech.transcript)
                }
            }) {
                Text(isRecording ? "停止錄音" : "開始錄音")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }

    func processSpeech(text: String) {
        OpenAIManager.shared.classify(note: text) { amount, category, note, date in
            if amount > 0 {
                viewModel.addTransaction(amount: amount, category: category, note: note, date: date)
                statusMessage = "✅ 已記帳：\(category) \(Int(amount))元（\(formatted(date))）"
            } else {
                statusMessage = "⚠️ 無法識別金額"
            }
        }
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
