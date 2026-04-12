import SwiftUI
import Observation

// MARK: - ViewModel

@Observable
@MainActor
final class RateServicesViewModel {
    // Injected Dependencies
    private let reviewOrderUC: ReviewOrderUC
    let orderId: Int
    
    // Form State
    var rating: Int = 3
    var reviewMessage: String = ""
    private(set) var isSubmitting: Bool = false
    
    // Presentation States
    var showErrorAlert: Bool = false
    private(set) var errorMessage: String = ""
    var showSuccessPopup: Bool = false
    
    init(orderId: Int, reviewOrderUC: ReviewOrderUC) {
        self.orderId = orderId
        self.reviewOrderUC = reviewOrderUC
    }
    
    func submitReview() async {
        isSubmitting = true
        
        do {
            let response = try await reviewOrderUC.execute(
                id: orderId,
                rate: rating,
                message: reviewMessage
            )
            
            isSubmitting = false
            
            // Adjust this condition based on how SimpleActionEntity handles success/failure
            if response.status == true {
                // Trigger the custom success popup
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.showSuccessPopup = true
                }
            } else {
                // Show API error message in standard alert
                self.errorMessage = response.message
                self.showErrorAlert = true
            }
            
        } catch {
            isSubmitting = false
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
}

// MARK: - Main View

struct RateServicesView: View {
    @State private var viewModel: RateServicesViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Closure to tell the parent view to dismiss itself
    var onSuccessDoubleDismiss: () -> Void

    init(viewModel: RateServicesViewModel, onSuccessDoubleDismiss: @escaping () -> Void) {
        _viewModel = State(wrappedValue: viewModel)
        self.onSuccessDoubleDismiss = onSuccessDoubleDismiss
    }

    var body: some View {
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                // Assuming TopRowNotForHome is defined elsewhere in your project
                TopRowNotForHome(
                    title: "Rate Us",
                    showBackButton: true,
                    kindOfTopRow: .none,
                    onBack: { dismiss() }
                )
                
                ScrollView {
                    VStack(spacing: 32) {
                        Image("RateUs")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .padding(.top, 16)

                        VStack(spacing: 12) {
                            Text("Rate Our Services")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundStyle(Color(red: 0.18, green: 0.49, blue: 0.36))

                            Text("Your Evaluation will referred to all the products you ordered in this order.")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        InteractiveRatingBox(rating: $viewModel.rating)
                            .padding(.horizontal, 24)
                        
                       

                       
                        
                        
                    GreenButton(title: "Submit", action: {
                        Task {
                            await viewModel.submitReview()
                        }
                    }) .disabled(viewModel.isSubmitting)
                    }
                }
            }
            // Add a slight blur to the background when popup is active
            .blur(radius: viewModel.showSuccessPopup ? 3 : 0)
            
            // The Success Popup Overlay
            if viewModel.showSuccessPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                EvaluationSuccessPopup {
                    // This triggers the double dismiss logic
                    dismiss() // 1. Dismiss this Rate view
                    onSuccessDoubleDismiss() // 2. Tell parent to dismiss itself
                }
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .zIndex(1) // Ensure it stays on top of the navigation bar
            }
        }
        .navigationBarHidden(true)
        // Standard alert only used for API errors now
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

// MARK: - Subcomponents

struct InteractiveRatingBox: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 16) {
            ForEach(1...5, id: \.self) { index in
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

struct EvaluationSuccessPopup: View {
    var onBackToOrder: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image("RateHasDone")
                .resizable()
                .scaledToFit()
                .frame(height: 220)
                .padding(.top, 16)
            
            Text("Your Evaluation Has Been\nReceived.")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(red: 0.33, green: 0.70, blue: 0.43))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Button {
                onBackToOrder()
            } label: {
                Text("Back To Order")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.30, green: 0.60, blue: 0.51))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding(32)
    }
}





