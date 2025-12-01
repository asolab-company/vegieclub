import SwiftUI

struct MenuView: View {
    var onSettings: () -> Void = {}
    var onAddNotes: () -> Void = {}
    var onIdeaDetails: (UUID) -> Void = { _ in }
    var onBestTime: () -> Void = {}

    @State private var selectedDate: Date = Calendar.current.startOfDay(
        for: Date()
    )

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {
                HStack {
                    Button(action: {}) {
                        Image("app_ic_sleep")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.init(hex: "0066DD"))
                    }
                    Spacer()

                    Button(action: { onSettings() }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.init(hex: "0066DD"))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)

                .frame(height: 50, alignment: .bottom)
                .background(
                    ZStack {
                        Color(hex: "FFFFFF")
                            .ignoresSafeArea()
                    }
                )

                SleepCalendarView(
                    selectedDate: $selectedDate,
                    onAddIdea: onAddNotes
                )

                NotesListView(
                    selectedDate: selectedDate,
                    onSelect: { idea in
                        onIdeaDetails(idea.id)
                    },
                    onAddIdea: onAddNotes,
                    onBestTime: onBestTime
                )
                .padding(.top, Device.isSmall ? 50 : 40)
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

struct NotesListView: View {
    var selectedDate: Date
    var onSelect: (IdeaRecord) -> Void = { _ in }
    var onAddIdea: () -> Void = {}
    var onBestTime: () -> Void = {}
    @State private var ideas: [IdeaRecord] = []
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("sleepReminderHour") private var sleepReminderHour: Int = 22
    @AppStorage("sleepReminderMinute") private var sleepReminderMinute: Int = 0

    private var reminderTimeText: String {
        String(format: "%02d:%02d", sleepReminderHour, sleepReminderMinute)
    }

    private var filteredIdeas: [IdeaRecord] {
        let calendar = Calendar.current
        return ideas.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if notificationsEnabled {
                    
                    Button(action: { onBestTime() }) {
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Best Sleep Reminder")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(hex: "02105B"))

                                Text(reminderTimeText)
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(Color(hex: "9C9ED4"))
                            }

                            Spacer()

                            Image(systemName: "bell.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(hex: "0066DD"))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "E6EDFF"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 40, style: .continuous)
                                .stroke(Color(hex: "A5B4FF"), lineWidth: 2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    }
                    .buttonStyle(.plain)
                } else {
                    
                    Button(action: { onBestTime() }) {
                        ZStack {
                            Text("Best Sleep Reminder")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)

                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BtnStyle(height: Device.isSmall ? 40 : 60))
                }

                if filteredIdeas.isEmpty {
                    EmptyNotesView()
                } else {
                    ForEach(
                        filteredIdeas.sorted(by: {
                            $0.createdAt > $1.createdAt
                        })
                    ) { idea in
                        NoteRow(idea: idea) {
                            onSelect(idea)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .onAppear(perform: fetch)
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name("Ideax.refreshIdeas")
            )
        ) { _ in
            fetch()
        }
    }

    private func fetch() {
        ideas = loadAllIdeas()
    }
}

private let noteDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "dd.MM.yyyy"
    return df
}()

private struct NoteRow: View {
    let idea: IdeaRecord
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(idea.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "02105B"))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(noteDateFormatter.string(from: idea.createdAt))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color(hex: "8B86C8"))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "0066DD"))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "E6EDFF"))
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct EmptyNotesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("app_bg_empty")
                .resizable()
                .scaledToFit()
                .frame(width: 114, height: 114)
                .opacity(0.9)

            Text("There are no notes in your list yet.")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color(hex: "9C9ED4"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct SleepCalendarView: View {
    @Binding var selectedDate: Date
    var onAddIdea: () -> Void = {}

    @State private var currentMonth: Date = Date()

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())

    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let circleSize = max(24, min(32, height / 11))
            let verticalSpacing = max(12, height * 0.04)
            let topPadding = max(8, height * 0.04)
            let buttonHeight: CGFloat =
                height < 320 ? 40 : (Device.isSmall ? 40 : 60)

            ZStack(alignment: .top) {

                LinearGradient(
                    colors: [Color(hex: "18337E"), Color(hex: "1B2356")],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: verticalSpacing) {
                    header
                    weekdayRow
                    calendarGrid(circleSize: circleSize)

                    Button(action: { onAddIdea() }) {
                        ZStack {
                            Text("How was your sleep")
                                .font(.system(size: 20, weight: .semibold))
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(
                                        .system(size: 18, weight: .bold)
                                    )
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BtnStyle(height: buttonHeight))
                    .padding(.bottom, 14)
                }
                .padding(.top, topPadding)
                .padding(.horizontal, 24)
            }
            .frame(width: proxy.size.width, height: height, alignment: .top)
        }
    }

    private var header: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.init(hex: "0066DD"))
            }
            .disabled(true)
            .opacity(0.4)

            Spacer()

            Text(monthTitle(for: currentMonth))
                .font(.system(size: 16, weight: .black))
                .foregroundColor(.white)

            Spacer()

            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.init(hex: "0066DD"))
            }
            .disabled(true)
            .opacity(0.4)
        }
    }

    private var weekdayRow: some View {
        let labels = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
        return HStack {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "FFFFFF"))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func calendarGrid(circleSize: CGFloat) -> some View {
        let days = makeDays(for: currentMonth)

        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: 7
        )

        return LazyVGrid(columns: columns, spacing: 18) {
            ForEach(days) { day in
                let isDisabled = day.date > today
                SleepDayCell(
                    day: day,
                    isSelected: isSameDay(day.date, selectedDate),
                    isDisabled: isDisabled,
                    circleSize: circleSize
                )
                .onTapGesture {
                    if day.isInCurrentMonth && !isDisabled {
                        selectedDate = day.date
                    }
                }
            }
        }
    }



    private func monthTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date).uppercased()
    }

    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(
            byAdding: .month,
            value: value,
            to: currentMonth
        ) {
            currentMonth = newDate
        }
    }

    private func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        return calendar.isDate(lhs, inSameDayAs: rhs)
    }

    private func makeDays(for month: Date) -> [CalendarDay] {

        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
            let firstWeekday = calendar.dateComponents(
                [.weekday],
                from: monthInterval.start
            ).weekday
        else { return [] }

        let weekdayOffset = (firstWeekday + 5) % 7

        var days: [CalendarDay] = []

        let totalCells = 35
        for i in 0..<totalCells {
            let offset = i - weekdayOffset
            let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: monthInterval.start
            )!

            let isInCurrentMonth = calendar.isDate(
                date,
                equalTo: month,
                toGranularity: .month
            )

            let dayNumber = calendar.component(.day, from: date)
            let hasRecord = isInCurrentMonth && dayNumber % 2 == 1

            let isDimmed: Bool
            if !isInCurrentMonth {
                isDimmed = true
            } else {
                isDimmed = dayNumber >= 24
            }

            days.append(
                CalendarDay(
                    id: date,
                    date: date,
                    isInCurrentMonth: isInCurrentMonth,
                    hasRecord: hasRecord,
                    isDimmed: isDimmed
                )
            )
        }
        return days
    }
}

struct CalendarDay: Identifiable {
    let id: Date
    let date: Date
    let isInCurrentMonth: Bool
    let hasRecord: Bool
    let isDimmed: Bool
}

private struct SleepDayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let isDisabled: Bool
    let circleSize: CGFloat

    private let calendar = Calendar.current

    var body: some View {
        let dayNumber = calendar.component(.day, from: day.date)

        ZStack {
            if isSelected {

                Circle()
                    .fill(Color(hex: "FF2D2D"))
                    .frame(width: circleSize, height: circleSize)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
            } else {
                Circle()
                    .stroke(
                        borderColor,
                        lineWidth: 2
                    )
                    .frame(width: circleSize, height: circleSize)
                    .opacity(day.isDimmed ? 0.4 : 1.0)
            }

            Text("\(dayNumber)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(textColor)
                .opacity(day.isInCurrentMonth ? 1.0 : 0.4)
        }
        .frame(maxWidth: .infinity)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var borderColor: Color {
        if !day.isInCurrentMonth {
            return Color(hex: "8490C6")
        }
        if day.hasRecord {
            return Color(hex: "0096FF")
        } else {
            return Color(hex: "7C89D9")
        }
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if day.isInCurrentMonth {
            return Color.white
        } else {
            return Color(hex: "C5D3FF")
        }
    }
}

#Preview {
    MenuView()
}
