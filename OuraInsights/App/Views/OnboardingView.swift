import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboarded: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "heart.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundStyle(.red)

            VStack(spacing: 12) {
                Text("Oura Insights")
                    .font(.largeTitle.bold())

                Text("Personal health analytics\npowered by your Oura Ring")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                isOnboarded = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
    }
}

#Preview {
    OnboardingView(isOnboarded: .constant(false))
}
