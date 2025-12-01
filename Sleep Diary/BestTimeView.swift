import SwiftUI

struct BestTimeView: View {
    var onBack: () -> Void

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("sleepReminderHour") private var sleepReminderHour: Int = 22
    @AppStorage("sleepReminderMinute") private var sleepReminderMinute: Int = 0

    @State private var title: String = ""
    @FocusState private var focusTitle: Bool
    @State private var hasInitialTimeLoaded = false
    @State private var showCalculate = false
    @State private var showInfo = false

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

    private var isSaveDisabled: Bool {
        guard let time = parsedTime else {
            return true
        }
        
        if !notificationsEnabled {
            return false
        }
        
        return time.hour == sleepReminderHour && time.minute == sleepReminderMinute
    }

    private var formattedCurrentTime: String {
        String(format: "%02d:%02d", sleepReminderHour, sleepReminderMinute)
    }
    
    private var isTimeInvalid: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && parsedTime == nil
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
                    Text("Best Sleep Reminder")
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
                
                HStack {
                    Button(action: { showCalculate = true }) {
                        ZStack {
                            Text("Calculate Your\nIdeal Sleep Time")
                                .font(.system(size: 16, weight: .semibold))
                                .multilineTextAlignment(.center)   
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)                 
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)                  
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BtnStyle(height: 60))
                    .padding(.bottom, 14)

                    Button(action: { showInfo = true }) {
                        ZStack {
                            Text("Best Sleep -\nInformation")
                                .font(.system(size: 16, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BtnStyle(height: 60))
                    .padding(.bottom, 14)
                }
                .padding(.horizontal,30)
                .padding(.top)

                Text(
                    "Get a reminder when it's the optimal time for you to go to sleep, based on your past sleep patterns."
                )
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.init(hex: "02105B"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 30)
                .padding(.top)
                
                RoundedField(
                    placeholder: "Enter the sleep time*",
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

                    guard let time = parsedTime else { return }

                    
                    sleepReminderHour = time.hour
                    sleepReminderMinute = time.minute

                    let schedule = {
                        NotificationManager.shared.scheduleDailyNotification(
                            hour: sleepReminderHour,
                            minute: sleepReminderMinute,
                            title: "Sleep Reminder 🌙",
                            body: "It’s time to get ready for sleep and log your day"
                        )
                    }

                    if !notificationsEnabled {
                        NotificationManager.shared.requestAuthorization { granted in
                            if granted {
                                notificationsEnabled = true
                                schedule()
                            }
                        }
                    } else {
                        
                        NotificationManager.shared.cancelAll()
                        schedule()
                    }
                }) {
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
                .padding(.horizontal,30)
                .padding(.top)

                Spacer()
            }

        }
        .onAppear {
            if !hasInitialTimeLoaded {
                title = formattedCurrentTime
                hasInitialTimeLoaded = true
            }
        }
        .fullScreenCover(isPresented: $showCalculate) {
            CalculateView {
                showCalculate = false
            }
        }
        .fullScreenCover(isPresented: $showInfo) {
            BestSleepInfo {
                showInfo = false
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
    BestTimeView { }
}
