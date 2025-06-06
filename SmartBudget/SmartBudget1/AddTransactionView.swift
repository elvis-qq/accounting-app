import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: TransactionViewModel

    @State private var amount: String = ""
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var date = Date()

    @State private var inputText = ""
    @StateObject private var speech = SpeechRecognizer()
    @State private var isRecording = false
    @State private var gptLoading = false
    @State private var statusMessage = ""

    var body: some View {
        NavigationView {
            Form {
                // 一句話 / 語音輸入區
                Section(header: Text("一句話輸入 / 語音輸入")) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextEditor(text: $inputText)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

                        if isRecording {
                            Text("🗣️ 即時辨識中...")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(speech.transcript)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }

                        HStack {
                            Button(action: {
                                gptLoading = true
                                analyzeInput(text: inputText)
                            }) {
                                Label("🧠 解析輸入", systemImage: "arrow.forward.circle.fill")
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                            Spacer()

                            Button(action: {
                                isRecording.toggle()
                                statusMessage = ""
                                if isRecording {
                                    speech.transcript = ""
                                    speech.startTranscribing()
                                } else {
                                    speech.stopTranscribing()
                                    inputText = speech.transcript
                                    gptLoading = true
                                    analyzeInput(text: speech.transcript)
                                }
                            }) {
                                Label(isRecording ? "停止錄音" : "語音輸入", systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .foregroundColor(isRecording ? .red : .blue)
                            }
                        }

                        if gptLoading {
                            ProgressView("GPT 分析中...")
                        }

                        if !statusMessage.isEmpty {
                            Text(statusMessage)
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                }

                // GPT 結果（可修改）區塊
                Section(header: Text("記帳資訊（可修改）")) {
                    TextField("金額", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("分類（如 飲食）", text: $category)

                    TextField("備註", text: $note)

                    DatePicker("日期", selection: $date, displayedComponents: .date)
                }

                // 儲存按鈕
                Section {
                    Button("💾 儲存記帳") {
                        if let amountValue = Double(amount) {
                            viewModel.addTransaction(amount: amountValue, category: category.isEmpty ? "未分類" : category, note: note, date: date)
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            statusMessage = "⚠️ 請輸入有效金額"
                        }
                    }
                }
            }
            .navigationTitle("新增記帳")
        }
    }

    // GPT 分析
    func analyzeInput(text: String) {
        OpenAIManager.shared.classify(note: text) { parsedAmount, parsedCategory, parsedNote, parsedDate in
            amount = String(format: "%.0f", parsedAmount)
            category = parsedCategory
            note = parsedNote
            date = parsedDate
            gptLoading = false
            statusMessage = "已自動填入欄位"
        }
    }
}
