import SwiftUI

private let ideasStoreKey = "SleepNotes"

func loadAllIdeas() -> [IdeaRecord] {
    guard let data = UserDefaults.standard.data(forKey: ideasStoreKey) else {
        return []
    }
    return (try? JSONDecoder().decode([IdeaRecord].self, from: data)) ?? []
}

private func deleteIdea(id: UUID) {
    var all = loadAllIdeas()
    if let idx = all.firstIndex(where: { $0.id == id }) {
        all.remove(at: idx)
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: ideasStoreKey)
        }
    }
}

struct DetailView: View {
    let ideaID: UUID
    var onBack: () -> Void = {}

    @State private var idea: IdeaRecord?
    @State private var showEdit: Bool = false

    private func fetch() {
        idea = loadAllIdeas().first(where: { $0.id == ideaID })
    }

    private func sleepDurationString(
        from startString: String,
        to endString: String
    ) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func timeToDate(_ time: String) -> Date? {
            let parts = time.split(separator: ":")
            guard parts.count == 2,
                let h = Int(parts[0]),
                let m = Int(parts[1]),
                (0...23).contains(h),
                (0...59).contains(m)
            else {
                return nil
            }
            return calendar.date(byAdding: .hour, value: h, to: today)?
                .addingTimeInterval(TimeInterval(m * 60))
        }

        guard let startDate = timeToDate(startString),
            var endDate = timeToDate(endString)
        else {
            return "-"
        }

        if endDate <= startDate {
            endDate =
                calendar.date(byAdding: .day, value: 1, to: endDate) ?? endDate
        }

        let components = calendar.dateComponents(
            [.hour, .minute],
            from: startDate,
            to: endDate
        )
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        if hours == 0 {
            return "\(minutes) min"
        } else if minutes == 0 {
            return "\(hours)h"
        } else {
            return "\(hours)h \(minutes)min"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {

            VStack(spacing: 0) {

                HStack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.init(hex: "0066DD"))
                    }

                    Spacer()
                    if let idea {
                        Text(idea.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.init(hex: "02105B"))
                    }

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color.init(hex: "0066DD"))

                    }.opacity(0)
                }
                .padding(.horizontal, 30)
                .padding(.bottom)
                .frame(height: 50, alignment: .bottom)
                .background(Color(hex: "FFFFFF").ignoresSafeArea())

                if let idea {
                    Text(idea.title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color.init(hex: "02105B"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)

                    if let start = idea.startTime, let end = idea.endTime {
                        Text("\(start) - \(end)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.init(hex: "02105B"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                            .padding(.top)

                        Text(
                            "Bedtime: \(sleepDurationString(from: start, to: end))"
                        )
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.init(hex: "02105B"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top)
                    } else if let start = idea.startTime {
                        Text("Bedtime start: \(start)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.init(hex: "02105B"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                            .padding(.top)
                    } else if let end = idea.endTime {
                        Text("Wake-up time: \(end)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(Color.init(hex: "02105B"))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 30)
                            .padding(.top)
                    }

                    Text(idea.details)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color.init(hex: "02105B"))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top)
                } else {

                    Text("Sleep not found")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.init(hex: "02105B"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                        .padding(.horizontal, 30)
                }

                Spacer()

                HStack {
                    Button(action: {
                        guard idea != nil else { return }
                        showEdit = true
                    }) {
                        Circle()
                            .fill(Color(hex: "0066DD"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image("ic_edit")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            )
                    }

                    Spacer()

                    Button(action: {
                        deleteIdea(id: ideaID)
                        NotificationCenter.default.post(
                            name: Notification.Name("Ideax.refreshIdeas"),
                            object: nil
                        )
                        onBack()
                    }) {
                        Circle()
                            .fill(Color(hex: "E30000"))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image("ic_delete")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }

        }
        .fullScreenCover(isPresented: $showEdit) {
            if let rec = idea {
                AddNote(
                    editRecord: rec,
                    onCancel: { showEdit = false },
                    onSaved: { _ in

                        fetch()
                        NotificationCenter.default.post(
                            name: Notification.Name("Ideax.refreshIdeas"),
                            object: nil
                        )
                        showEdit = false
                    }
                )
            } else {

                AddNote(onCancel: { showEdit = false })
            }
        }
        .background(
            ZStack {
                Color(hex: "F7F8F9")
                    .ignoresSafeArea()

            }

        )
        .onAppear { fetch() }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name("Ideax.refreshIdeas")
            )
        ) { _ in
            fetch()
        }
    }
}

#Preview {
    DetailPreviewWrapper()
}

private struct DetailPreviewWrapper: View {
    let sample: IdeaRecord

    init() {

        let rec = IdeaRecord(
            id: UUID(),
            title: "Great sleep idea",
            details: """
                Tonight I tried going to bed earlier and avoided screens 1 hour before sleep.
                Felt much more relaxed and fell asleep faster.
                """,
            createdAt: Date(),
            startTime: "21:10",
            endTime: "07:00"
        )
        self.sample = rec

        let all = [rec]
        if let data = try? JSONEncoder().encode(all) {
            UserDefaults.standard.set(data, forKey: ideasStoreKey)
        }
    }

    var body: some View {
        DetailView(
            ideaID: sample.id,
            onBack: {}
        )
    }
}
