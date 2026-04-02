import SwiftUI

struct TopRow: View {

    var body: some View {
        HStack {
            // Directly reference the method
            Button("language_switch_title".localized(), action: changeLanguage)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image("navigationLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 28)

            Button("navigation_skip".localized(), action: handleSkip)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.headline)
        .frame(height: 70)
        .padding(.horizontal, 18)
        .foregroundStyle(.black)
        .background {
            Color.clear
                .overlay {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .ignoresSafeArea(edges: .top)
        }
    }
    
    // Mark as @MainActor to safely update the UI when MOLH.reset() is called
    @MainActor
    private func changeLanguage() {
        // Toggle purely based on the current state
        let newLanguage = Constants.shared.isAR ? "en" : "ar"
        
        UserDefaults.standard.set(true, forKey: Constants.shared.resetLanguage)
        MOLH.setLanguageTo(newLanguage)
        MOLH.reset()
    }
    
    @MainActor
    private func handleSkip() {
        GenericUserDefault.shared.setValue(true, "pressSkip")
        MOLH.reset()
    }
}
