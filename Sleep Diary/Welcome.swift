import SwiftUI

struct Welcome: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        Image("app_bg_welcome")
                            .resizable()
                            .scaledToFit()
                            .padding(.vertical)

                        Group {
                            Text("🌙 Key Features of Sleep Diary")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 15 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text("1.🕒 Easy Sleep Tracking")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 15 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "Log your bedtime and wake-up time in seconds — no complicated setup."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)

                            Text("2.💭 Sleep Notes")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 15 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "Write about your dreams, mood, or how well you slept."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)

                            Text("3.📈 Smart Insights")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 15 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "See your average sleep duration and discover patterns over time."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)

                            Text("4.🧘 Improve Your Rest")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 15 : 18,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "Understand what helps you sleep better and feel more refreshed."
                            )
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .multilineTextAlignment(.leading)
                            .padding(.bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: { onContinue() }) {
                            ZStack {
                                Text("Continue")
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
                        .buttonStyle(BtnStyle(height: Device.isSmall ? 40 : 60))
                        .padding(.bottom, 8)

                        TermsFooter().padding(
                            .bottom,
                            Device.isSmall ? 20 : 60
                        )
                    }
                    .padding(.horizontal, 30)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(hex: "18337E"),
                            Color(hex: "1B2356"),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                }
            )
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "8B86C8"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "8B86C8"))
                    .font(.footnote)

                Link("Terms Of Use", destination: Data.terms)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "0066DD"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "8B86C8"))
                    .font(.footnote)

                Link("Privacy Policy", destination: Data.policy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "0066DD"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    Welcome {
        print("Finished")
    }
}
