import SwiftUI
import UIKit

private let ideasStoreKey = "SleepNotes"

struct IdeaRecord: Identifiable, Codable {
    let id: UUID
    let title: String
    let details: String
    let createdAt: Date
    var startTime: String? = nil
    var endTime: String? = nil
}

private func loadIdeas() -> [IdeaRecord] {
    guard let data = UserDefaults.standard.data(forKey: ideasStoreKey) else {
        return []
    }
    return (try? JSONDecoder().decode([IdeaRecord].self, from: data)) ?? []
}

@discardableResult
private func persistIdea(
    title: String,
    details: String,
    startTime: String?,
    endTime: String?
) -> IdeaRecord {
    var all = loadIdeas()
    let record = IdeaRecord(
        id: UUID(),
        title: title,
        details: details,
        createdAt: Date(),
        startTime: startTime,
        endTime: endTime
    )
    all.append(record)
    if let data = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(data, forKey: ideasStoreKey)
    }
    return record
}

private func updateIdea(
    id: UUID,
    title: String,
    details: String,
    startTime: String?,
    endTime: String?
) -> IdeaRecord? {
    var all = loadIdeas()
    guard let idx = all.firstIndex(where: { $0.id == id }) else { return nil }
    let updated = IdeaRecord(
        id: id,
        title: title,
        details: details,
        createdAt: all[idx].createdAt,
        startTime: startTime,
        endTime: endTime
    )
    all[idx] = updated
    if let data = try? JSONEncoder().encode(all) {
        UserDefaults.standard.set(data, forKey: ideasStoreKey)
    }
    return updated
}

struct AddNote: View {
    var editRecord: IdeaRecord? = nil
    var onCancel: () -> Void
    var onSaved: (_ saved: IdeaRecord) -> Void = { _ in }

    @State private var title: String = ""
    @State private var startTime: String = ""
    @State private var endTime: String = ""
    @State private var details: String = ""
    @FocusState private var focusTitle: Bool

    var body: some View {
        ZStack {

            Color(hex: "F7F8F9")
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }

            VStack(spacing: 0) {

                HStack {
                    Button(action: {
                        resetFields()
                        onCancel()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "0066DD"))
                    }

                    Spacer()

                    Button(action: {
                        resetFields()

                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(hex: "E30000"))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .frame(height: 50, alignment: .bottom)
                .background(
                    Color.white
                        .ignoresSafeArea(edges: .top)
                )
                .overlay(alignment: .center) {
                    Text(editRecord == nil ? "Add Idea" : "Edit Idea")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "02105B"))
                        .allowsHitTesting(false)
                }

                ScrollView {
                    VStack(spacing: 16) {

                        Group {
                            Text("Idea title*")
                                .foregroundColor(Color(hex: "02105B"))
                                .font(.system(size: 16, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                                .padding(.top, 20)

                            RoundedField(
                                placeholder: "Enter the Idea title",
                                text: $title,
                                multiline: false,
                                focus: $focusTitle
                            )
                        }
                        .padding(.horizontal)

                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bedtime start")
                                    .foregroundColor(Color(hex: "02105B"))
                                    .font(.system(size: 16, weight: .regular))
                                    .padding(.leading)

                                TimeField(
                                    text: $startTime,
                                    isValid: isStartTimeValid
                                )
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Bedtime end")
                                    .foregroundColor(Color(hex: "02105B"))
                                    .font(.system(size: 16, weight: .regular))
                                    .padding(.leading)

                                TimeField(
                                    text: $endTime,
                                    isValid: isEndTimeValid
                                )
                            }
                        }
                        .padding(.horizontal)

                        Group {
                            Text("Note*")
                                .foregroundColor(Color(hex: "02105B"))
                                .font(.system(size: 16, weight: .regular))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)

                            RoundedField(
                                placeholder: "Enter the Details / Notes",
                                text: $details,
                                multiline: true
                            )
                        }
                        .padding(.horizontal)

                        Button(action: saveIdea) {
                            ZStack {
                                Text("Save")
                                    .font(.system(size: 20, weight: .semibold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle(height: 60))
                        .disabled(isSaveDisabled)
                        .opacity(isSaveDisabled ? 0.5 : 1.0)
                        .padding(.horizontal)

                        Spacer(minLength: 24)
                    }
                }
                .gesture(
                    TapGesture()
                        .onEnded {
                            hideKeyboard()
                        }
                )
            }
        }
        .onAppear {
            DispatchQueue.main.async { focusTitle = true }

            if let rec = editRecord {
                if title.isEmpty { title = rec.title }
                if details.isEmpty { details = rec.details }
                if startTime.isEmpty, let s = rec.startTime { startTime = s }
                if endTime.isEmpty, let e = rec.endTime { endTime = e }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var isSaveDisabled: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !isStartTimeValid || !isEndTimeValid
    }

    private var isStartTimeValid: Bool {
        isTimeValid(startTime)
    }

    private var isEndTimeValid: Bool {
        isTimeValid(endTime)
    }

    private func isTimeValid(_ input: String) -> Bool {
        let digits = input.filter { $0.isNumber }
        if digits.isEmpty { return true }

        guard digits.count == 4 else { return false }

        let hoursStr = String(digits.prefix(2))
        let minutesStr = String(digits.suffix(2))

        guard let h = Int(hoursStr), let m = Int(minutesStr) else {
            return false
        }
        return (0...23).contains(h) && (0...59).contains(m)
    }

    private func normalizeTime(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let parts = trimmed.split(separator: ":")
        if parts.count == 2,
            let h = Int(parts[0]),
            let m = Int(parts[1]),
            (0...23).contains(h),
            (0...59).contains(m)
        {
            return String(format: "%02d:%02d", h, m)
        }

        return trimmed
    }

    private func resetFields() {
        title = ""
        startTime = ""
        endTime = ""
        details = ""
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }

    private func saveIdea() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDetails = details.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedTitle.isEmpty, !trimmedDetails.isEmpty else { return }

        let normalizedStart = normalizeTime(startTime)
        let normalizedEnd = normalizeTime(endTime)

        if let normalizedStart { startTime = normalizedStart }
        if let normalizedEnd { endTime = normalizedEnd }

        if let rec = editRecord,
            let updated = updateIdea(
                id: rec.id,
                title: trimmedTitle,
                details: trimmedDetails,
                startTime: normalizedStart,
                endTime: normalizedEnd
            )
        {
            NotificationCenter.default.post(
                name: Notification.Name("Ideax.refreshIdeas"),
                object: nil
            )
            onSaved(updated)
            resetFields()
            onCancel()
        } else {
            let saved = persistIdea(
                title: trimmedTitle,
                details: trimmedDetails,
                startTime: normalizedStart,
                endTime: normalizedEnd
            )
            NotificationCenter.default.post(
                name: Notification.Name("Ideax.refreshIdeas"),
                object: nil
            )
            onSaved(saved)
            resetFields()
            onCancel()
        }
    }
}

private struct RoundedField: View {
    let placeholder: String
    @Binding var text: String
    var multiline: Bool = false
    var minHeight: CGFloat = 44
    var multilineHeight: CGFloat = 138
    var focus: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {
            if multiline {
                ZStack(alignment: .topLeading) {

                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(hex: "8B86C8"))
                            .font(.system(size: 16, weight: .regular))
                            .padding(.leading, 10)
                            .padding(.top, 8)
                    }

                    ScrollTextView(text: $text)
                        .frame(height: multiline ? multilineHeight : minHeight)
                }
            } else {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(hex: "8B86C8"))
                            .font(.system(size: 16, weight: .regular))
                            .padding(.horizontal, 10)
                    }

                    Group {
                        if let focus {
                            TextField("", text: $text)
                                .focused(focus)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .foregroundColor(Color(hex: "003365"))
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 10)
                    .frame(height: minHeight)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "E6EDFF"))
        )
    }
}

private struct TimeField: View {
    @Binding var text: String
    var isValid: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text("HH:MM")
                    .foregroundColor(Color(hex: "8B86C8"))
                    .font(.system(size: 16, weight: .regular))
                    .padding(.horizontal, 10)
            }

            TextField(
                "",
                text: Binding(
                    get: { text },
                    set: { newValue in

                        let digitsOnly = newValue.filter { $0.isNumber }
                        var trimmed = String(digitsOnly.prefix(4))

                        var formatted = ""
                        let count = trimmed.count

                        if count == 0 {
                            formatted = ""
                        } else if count <= 2 {

                            formatted = trimmed
                        } else {

                            let hEnd = trimmed.index(
                                trimmed.startIndex,
                                offsetBy: 2
                            )
                            let hours = trimmed[trimmed.startIndex..<hEnd]
                            let minutes = trimmed[hEnd..<trimmed.endIndex]
                            formatted = "\(hours):\(minutes)"
                        }

                        if formatted != text {
                            text = formatted
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .foregroundColor(Color(hex: "003365"))
            .font(.system(size: 16, weight: .regular))
            .padding(.horizontal, 10)
            .frame(height: 44)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "E6EDFF"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isValid ? Color.clear : Color.red,
                            lineWidth: isValid ? 0 : 2
                        )
                )
        )
    }
}

private struct ScrollTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isScrollEnabled = true
        tv.textContainerInset = UIEdgeInsets(
            top: 8,
            left: 10,
            bottom: 8,
            right: 10
        )
        tv.textContainer.lineFragmentPadding = 0
        tv.font = .systemFont(ofSize: 16, weight: .regular)
        tv.textColor = UIColor(Color(hex: "003365"))
        tv.delegate = context.coordinator
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        uiView.font = .systemFont(ofSize: 16, weight: .regular)
        uiView.textColor = UIColor(Color(hex: "003365"))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: ScrollTextView
        init(_ parent: ScrollTextView) { self.parent = parent }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

#Preview {
    AddNote(onCancel: {}, onSaved: { _ in })
}
