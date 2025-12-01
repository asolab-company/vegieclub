import SwiftUI

struct BestSleepInfo: View {
    var onBack: () -> Void

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
                    Text("Best Sleep - Information")
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

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {

                        
                        Group {
                            Text("🌙 When Is the Best Time to Fall Asleep?")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "02105B"))

                            Text(
                                """
                                Finding the right time to fall asleep can make a big difference in how rested and energized you feel. While everyone’s body is a little different, science shows that there are general guidelines that work well for most people.
                                """
                            )
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "02105B"))
                        }

                        
                        Group {
                            Text("⭐ The Ideal Sleep Window")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "02105B"))

                            Text(
                                """
                                For most adults, the best time to fall asleep is:
                                Between 9:00 PM and 11:00 PM
                                During this period, your body naturally increases melatonin production, making it easier to fall asleep and enter deep, restorative sleep.
                                """
                            )
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "02105B"))
                        }

                        
                        Group {
                            Text("⭐ Sync With Your Wake-Up Time")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "02105B"))

                            Text(
                                """
                                A simple rule:
                                Count back 7–9 hours from when you need to wake up.
                                Examples:
                                • Wake up at 7:00 AM → Ideal bedtime: 10:00–11:00 PM
                                • Wake up at 6:00 AM → Ideal bedtime: 9:30–10:30 PM
                                """
                            )
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "02105B"))
                        }

                        
                        Group {
                            Text("⭐ Know Your Chronotype")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "02105B"))

                            Text(
                                """
                                Everyone has a natural “internal clock”:
                                • Early Birds: Best asleep by 8:00–10:00 PM
                                • Night Owls: Best asleep by 10:00 PM–12:00 AM
                                • Neutral Types: Best asleep by 9:30–11:00 PM
                                Finding your personal rhythm helps you sleep more efficiently.
                                """
                            )
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "02105B"))
                        }

                        
                        Group {
                            Text("⭐ What’s Most Important")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "02105B"))

                            Text(
                                """
                                Whatever time you choose, be consistent.
                                Going to bed and waking up at the same time every day helps:
                                • Improve sleep quality
                                • Boost energy levels
                                • Stabilize mood
                                • Support overall health
                                Your body thrives on routine.
                                """
                            )
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "02105B"))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }

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
    BestSleepInfo {}
}
