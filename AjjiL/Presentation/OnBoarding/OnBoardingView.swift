import SwiftUI


struct OnBoardingView: View {
    var window: UIWindow?
    
    
    init(window: UIWindow? = nil) {
        self.window = window
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("onboarding1")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 0)
                    .frame(height : 600)
                  
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        Text("Best Quality At\nYour Hand!")
                            .font(.custom("Poppins-Bold", size: 38))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.primary)
                        
                        Group {
                            Text("Explore the top collection of ")
                            + Text("AJJIL\n")
                                .foregroundStyle(.orange)
                                .fontWeight(.semibold)
                            + Text("and buy and sell your items as well. ")
                        }
                        .font(.custom("Poppins-Regular", size: 18))
                    }
                    
                    SlideToStartButton {
                        // 3. Mark onboarding as complete using your constants
                        GenericUserDefault.shared.setValue(true, Constants.shared.onboarding)
                        
                        // 4. Trigger the UIWindow transition
                        authorizationTransition()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .offset(y: -60)
                
                Spacer()
            }
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Root Transitions
    
    func authorizationTransition() {
        guard let window = self.window else { return }
        
        let loginView = LogInView()
            .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
        
        let hostingController = UIHostingController(rootView: loginView)
        changeRoot(hostingController, in: window)
    }
    

    
    // Change rootView with cross dissolve animation
    private func changeRoot(_ vc: UIViewController, in window: UIWindow) {
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: nil)
    }
}

#Preview {
    OnBoardingView(window: nil)
}
