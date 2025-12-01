import SwiftUI

struct SettingsView: View {
    var onBack: () -> Void
    @Environment(\.openURL) private var openURL
    @State private var showShare = false
    
    
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("sleepReminderHour") private var sleepReminderHour: Int = 22
    @AppStorage("sleepReminderMinute") private var sleepReminderMinute: Int = 0

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
                    Text("Setting")
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

                SettingsRow(
                    icon: "app_ic_share",
                    title: "Share app",
                    action: { showShare = true }
                )
                .padding(.top, 20)

                SettingsRow(
                    icon: "app_ic_terms",
                    title: "Terms and Conditions",
                    action: { openURL(Data.terms) }
                )

                SettingsRow(
                    icon: "app_ic_privacy",
                    title: "Privacy",
                    action: { openURL(Data.policy) }
                )

                SettingsRow(
                    icon: "app_ic_not",
                    title: "Notifications",
                    showsNotificationState: true,
                    isNotificationOn: notificationsEnabled
                ) {
                    if !notificationsEnabled {
                        
                        NotificationManager.shared.requestAuthorization { granted in
                            if granted {
                                notificationsEnabled = true
                                
                                NotificationManager.shared.scheduleDailyNotification(
                                    hour: sleepReminderHour,
                                    minute: sleepReminderMinute,
                                    title: "Sleep Reminder 🌙",
                                    body: "It’s time to get ready for sleep and log your day"
                                )
                            } else {
                                notificationsEnabled = false
                                
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    openURL(url)
                                }
                            }
                        }
                    } else {
                        
                        notificationsEnabled = false
                        NotificationManager.shared.cancelAll()
                    }
                }

                Spacer()
            }

        }
        .onAppear {
            
            
            
            
            NotificationManager.shared.getCurrentStatus { granted in
                
                
                if !granted && notificationsEnabled {
                    notificationsEnabled = false
                    NotificationManager.shared.cancelAll()
                }
            }
        }
        .background(
            ZStack {
                Color(hex: "F7F8F9")
                    .ignoresSafeArea()
            }
        )
        .sheet(isPresented: $showShare) {
            ShareSheet(items: Data.shareItems)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct SettingsRow: View {
    let icon: String
    let title: String
    let showsNotificationState: Bool
    let isNotificationOn: Bool
    let action: () -> Void

    init(
        icon: String,
        title: String,
        showsNotificationState: Bool = false,
        isNotificationOn: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.showsNotificationState = showsNotificationState
        self.isNotificationOn = isNotificationOn
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "02105B"))

                Spacer()

                
                if showsNotificationState {
                    Image(systemName: isNotificationOn ? "bell.fill" : "bell")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "0066DD"))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "0066DD"))
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "E6EDFF"))
            .clipShape(Capsule())
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    func updateUIViewController(
        _ vc: UIActivityViewController,
        context: Context
    ) {}
}

#Preview {
    SettingsView { }
}
