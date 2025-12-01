import SwiftUI

struct CalculateView: View {
    var onBack: () -> Void

    @State private var title: String = ""
    @FocusState private var focusTitle: Bool
    @State private var results: [String] = []

    private var timeBinding: Binding<String> {
        Binding(
            get: { title },
            set: { newValue in
                
                let digits = newValue.filter { $0.isNumber }
                
                let limited = String(digits.prefix(4))

                var result: String
                switch limited.count {
                case 0:
                    result = ""
                case 1:
                    
                    result = limited
                case 2:
                    
                    result = limited + ":"
                case 3:
                    
                    let idx = limited.index(limited.startIndex, offsetBy: 2)
                    let hh = limited[..<idx]
                    let mm = limited[idx...]
                    result = String(hh) + ":" + String(mm)
                case 4:
                    
                    let idx = limited.index(limited.startIndex, offsetBy: 2)
                    let hh = limited[..<idx]
                    let mm = limited[idx...]
                    result = String(hh) + ":" + String(mm)
                default:
                    result = limited
                }

                title = result
            }
        )
    }

    
    private var parsedTime: (hour: Int, minute: Int)? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let components = trimmed.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute) else {
            return nil
        }
        return (hour, minute)
    }

    private var isTimeInvalid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && parsedTime == nil
    }

    private var isCalculateDisabled: Bool {
        parsedTime == nil
    }

    private func formatted(_ totalMinutes: Int) -> String {
        let minutesInDay = 24 * 60
        let normalized = (totalMinutes % minutesInDay + minutesInDay) % minutesInDay
        let hour = normalized / 60
        let minute = normalized % 60
        return String(format: "%02d:%02d", hour, minute)
    }

    private func calculateBedtimes() {
        guard let time = parsedTime else {
            results = []
            return
        }
        let wakeMinutes = time.hour * 60 + time.minute

        
        let cycles = [6, 5, 4]
        let bedtimes = cycles.map { cyclesCount -> String in
            let minutesToSubtract = cyclesCount * 90
            let bedtimeMinutes = wakeMinutes - minutesToSubtract
            return formatted(bedtimeMinutes)
        }
        results = bedtimes
    }

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "0066DD"))
                    }
                    Spacer()
                    Text("Calculate Your Ideal Sleep Time")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "02105B"))
                    Spacer()
                    Image(systemName: "chevron.left")
                        .opacity(0)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .frame(height: 50, alignment: .bottom)
                .background(
                    ZStack {
                        Color(hex: "FFFFFF")
                            .ignoresSafeArea()
                    }
                )
                
                Text(
                    "Start with the time you need to wake up. This is your anchor for calculating a healthy sleep schedule."
                )
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.init(hex: "02105B"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top)

                
                RoundedField(
                    placeholder: "Enter the wake-up time*",
                    text: timeBinding,
                    multiline: false,
                    focus: $focusTitle
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isTimeInvalid ? Color.red : Color.clear, lineWidth: 1)
                )
                .padding(.horizontal,30)
                .padding(.top)
                
                
                Button(action: {
                    focusTitle = false
                    calculateBedtimes()
                }) {
                    ZStack {
                        Text("Calculate")
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
                .disabled(isCalculateDisabled)
                .opacity(isCalculateDisabled ? 0.5 : 1.0)
                .padding(.horizontal,30)
                .padding(.top)

                if let first = results.first, let last = results.last {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ideal bedtime:")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "02105B"))

                        Text("\(first) - \(last)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "02105B"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 16)
                }
                
           Spacer()

            }

        }

        .background(
            ZStack {
                Color(hex: "F7F8F9")
                    .ignoresSafeArea()
            }
        )

    }
}

#Preview {
    CalculateView {}
}
