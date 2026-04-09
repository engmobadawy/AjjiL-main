import SwiftUI

struct RateServicesView: View {
    // Marked private as per state management rules
    @State private var rating: Int = 3

    var body: some View {
        VStack(spacing: 32) {
            // Header Image
            Image("RateUs")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)

            // Text Content
            VStack(spacing: 12) {
                Text("Rate Our Services")
                    .font(.title)
                    .fontWeight(.bold)
                    // Using foregroundStyle as per modern API guidelines
                    .foregroundStyle(Color(red: 0.18, green: 0.49, blue: 0.36)) 

                Text("Your Evaluation will referred to all the products you ordered in this order.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            // Extracted interactive component
            InteractiveRatingBox(rating: $rating)

            Spacer()
        }
        .padding()
    }
}

struct InteractiveRatingBox: View {
    // Using @Binding because this child needs to modify the parent's state
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 16) {
            // Using stable identity \.self for a static range
            ForEach(1...5, id: \.self) { index in
                // Using Button instead of onTapGesture()
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(index <= rating ? .orange : .gray.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    RateServicesView()
}