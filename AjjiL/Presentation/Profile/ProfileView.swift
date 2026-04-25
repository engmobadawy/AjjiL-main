import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var navigateToPersonalData = false
    @State private var navigateToPrivacyPolicy = false
    @State private var navigateToTermsAndConditionView = false
    @State private var navigateToAboutUsView = false
    @State private var navigateToSettings = false
    @State private var navigateToContactUsView = false
    @State private var navigateToCouponsView = false
    @State private var navigateToPromoCodeCardView = false
    @State private var navigateToMyPointsView = false
    
    
    
    
    
   
    
    @Environment(TabRouter.self) private var tabRouter
    
    
    
    
    init() {
        let networkService = NetworkService()
        let repository = ProfileRepositoryImp(networkService: networkService)
        let useCase = GetProfileUC(repo: repository)
        let vm = ProfileViewModel(getProfileUC: useCase)
        
        _viewModel = State(initialValue: vm)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopRowNotForHome(
                    title: "profile",
                    showBackButton: false,
                    kindOfTopRow: .justNotification
                )
                
                ScrollView {
                    VStack(spacing: 15) {
                        
                        // Profile Avatar Section
                        Button {
                            navigateToPersonalData = true
                        } label: {
                            StoresAvatarView(image: viewModel.profileImage)
                        }
                        .buttonStyle(.plain)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if let profile = viewModel.profile {
                            // User Info Display
                            Text(profile.name)
                                .font(.custom("Poppins-Bold", size: 22))
                            
                            HStack(spacing: 4) {
                                Image("CallToRight")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 14, height: 14)
                                
                                Text("+966 \(profile.phoneNumber)")
                                    .font(.custom("Poppins-Regular", size: 18))
                                    .foregroundStyle(.secondary)
                            }
                        } else if let errorMessage = viewModel.errorMessage {
                            // Error / Empty State
                            errorStateView(message: errorMessage)
                        }
                        
                        qrProfileButton
                            .padding(.top, 10)
                        
                        // Menu List UI
                        menuSection
                            .padding(.top, 16)
                        
                        WhiteButton(title: "Sign Out", action: {
                            GenericUserDefault.shared.removeValue(Constants.shared.token)
                            MOLH.reset()
                        })
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .task {
                // Initial fetch
                await viewModel.fetchProfile()
            }
            // Destination: Personal Data
            .navigationDestination(isPresented: $navigateToPersonalData) {
                let networkService = NetworkService()
                let repository = ProfileRepositoryImp(networkService: networkService)
                let updateUseCase = UpdateProfileInfoUC(repo: repository)
                
                PersonalDataView(
                    updateProfileInfoUC: updateUseCase,
                    username: viewModel.profile?.name ?? "",
                    email: viewModel.profile?.email ?? "",
                    profileImage: viewModel.profileImage
                ) {
                    Task {
                        await viewModel.fetchProfile(forceRefresh: true)
                    }
                }
            }
            // 👈 Destination: Settings
            .navigationDestination(isPresented: $navigateToSettings) {
                SettingsView()
            }
            
            .navigationDestination(isPresented: $navigateToPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .navigationDestination(isPresented: $navigateToTermsAndConditionView) {
                TermsAndConditionView()
            }
            .navigationDestination(isPresented: $navigateToAboutUsView) {
                AboutUsView()
            }
            .navigationDestination(isPresented: $navigateToMyPointsView) {
                            // 1. Initialize Network & Repository
                            let networkService = NetworkService()
                            let repository = PointRepositoryImp(networkService: networkService)
                            
                            // 2. Initialize Use Cases
                            let getPointsUC = GetPointsUC(repo: repository)
                            let redeemPointsUC = RedeemPointsUC(repo: repository)
                            let calcPointsUC = CalcPointsUC(repo: repository)
                            
                            // 3. Initialize ViewModel
                            let viewModel = PointsViewModel(
                                getPointsUC: getPointsUC,
                                redeemPointsUC: redeemPointsUC,
                                calcPointsUC: calcPointsUC
                            )
                            
                            // 4. Inject into the View
                            MyPointsView(viewModel: viewModel)
                        }
            
            
            .navigationDestination(isPresented: $navigateToCouponsView) {
                            // 1. Initialize Network & Repository
                            let networkService = NetworkService()
                            let repository = CouponsRepositoryImp(networkService: networkService)
                            
                            // 2. Initialize Use Case
                            let getCouponsUC = GetCouponsUseCase(repository: repository)
                            
                            // 3. Initialize ViewModel
                            let viewModel = CouponsViewModel(getCouponsUseCase: getCouponsUC)
                            
                            // 4. Inject into the View
                            CouponsView(viewModel: viewModel)
                        }
            
            
            .navigationDestination(isPresented: $navigateToPromoCodeCardView) {
                // 1. Initialize Network & Repository
                let networkService = NetworkService()
                let repository = ProfileRepositoryImp(networkService: networkService)
                
                // 2. Initialize Use Case
                let getPromoCodesUC = GetPromoCodesUC(repo: repository)
                
                // 3. Initialize ViewModel
                let viewModel = PromoCodesViewModel(getPromoCodesUC: getPromoCodesUC)
                
                // 4. Inject into the View
                PromoCodesView(viewModel: viewModel)
            }
            
            .navigationDestination(isPresented: $navigateToContactUsView) {
                            // 1. Initialize Network & Repository
                            let networkService = NetworkService()
                            let repository = ContactRepositoryImp(networkService: networkService)
                            
                            // 2. Initialize Use Cases
                            let getContactTypesUC = GetContactTypesUseCase(repository: repository)
                            let sendContactUsUC = SendContactUsUseCase(repository: repository)
                            
                            // 3. Initialize ViewModel
                            let viewModel = ContactUsViewModel(
                                getContactTypesUseCase: getContactTypesUC,
                                sendContactUsUseCase: sendContactUsUC
                            )
                            
                            // 4. Inject into the View
                            ContactUsView(viewModel: viewModel)
                        }
            
            
            
            
            
            
            
        }
    }
}

// MARK: - Subviews
private extension ProfileView {
    
    @ViewBuilder
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Text("welcome".localized())
                .font(.custom("Poppins-Bold", size: 24))
            
            Text("get_profile_ready".localized())
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.secondary)
            
            Button {
                navigateToPersonalData = true
            } label: {
                Image("car")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 113, height: 113)
                    .padding(15)
                    .background(Color(red: 202/255, green: 251/255, blue: 242/255))
                    .clipShape(.circle)
                    .overlay {
                        Circle()
                            .stroke(Color.customOrange, lineWidth: 3)
                    }
            }
            .buttonStyle(.plain)
            
            Text(message)
                .foregroundStyle(.red)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
    }
    
    var qrProfileButton: some View {
        Button {
            // Handle QR Action
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text("QR Profile Code".localized())
                    .font(.custom("Poppins-Regular", size: 18))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.brandGreen) // Assuming brand green exists
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    // MARK: - Menu List Section
    var menuSection: some View {
        VStack(spacing: 12) {
            ProfileMenuRow(iconName: "bag", title: "My Orders") {
                // Navigate to My Orders
                tabRouter.selectedTab = 1
            }
            
            ProfileMenuRow(iconName: "gift", title: "My Points") {
                // Navigate to My Points
                navigateToMyPointsView = true
            }
            
            ProfileMenuRow(iconName: "percent", title: "Coupons") {
                // Navigate to Coupons
                
                navigateToCouponsView = true
            }
            
            ProfileMenuRow(iconName: "ticket", title: "Promo Code") {
                // Navigate to Promo Code
                navigateToPromoCodeCardView = true
            }
            
            // 👈 Settings Navigation Triggered Here
            ProfileMenuRow(iconName: "gearshape", title: "Settings") {
                navigateToSettings = true
            }
            
            // Note: Language Row has been completely removed from here.
            
            ProfileMenuRow(iconName: "phone", title: "Contact Us") {
                // Navigate to Contact Us
                navigateToContactUsView = true
            }
            
            ProfileMenuRow(iconName: "info.circle", title: "About Us") {
                // Navigate to About Us
                navigateToAboutUsView = true
            }
            
            ProfileMenuRow(iconName: "checkmark.shield", title: "Privacy Policy") {
                // Navigate to Privacy Policy
                navigateToPrivacyPolicy = true
            }
            
            ProfileMenuRow(iconName: "ellipsis.message", title: "Terms & Conditions") {
                // Navigate to Terms & Conditions
                navigateToTermsAndConditionView = true
            }
            
            ProfileMenuRow(iconName: "trash", title: "Delete Account") {
                // Handle Delete Account
            }
        }.padding(.bottom , 12)
    }
}

// MARK: - Reusable Menu Row Component
struct ProfileMenuRow: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
                
                Text(title.localized())
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}





import SwiftUI


struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var isPushNotificationEnabled: Bool = true
    @State private var navigateToLanguage: Bool = false
    @State private var navigateToChangePassword: Bool = false // 👈 1. Added state for navigation
    @State private var navigateToChangePhone: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Custom Top Row
            TopRowNotForHome(
                title: "Settings".localized(),
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 1. Push Notification Toggle
                    SettingsToggleRow(
                        iconName: "bell",
                        title: "Push Notification",
                        isOn: $isPushNotificationEnabled
                    )
                    
                    // 2. Language Row
                    SettingsNavigationRow(
                        iconName: "globe",
                        title: "Language",
                        valueText: "English"
                    ) {
                        navigateToLanguage = true
                    }
                    
                    // 3. Change Password
                    SettingsNavigationRow(
                        iconName: "lock",
                        title: "Change Password"
                    ) {
                        navigateToChangePassword = true // 👈 2. Trigger navigation on tap
                    }
                    
                    // 4. Change Phone Number
                    SettingsNavigationRow(
                        iconName: "phone",
                        title: "Change Phone Number"
                    ) {
                        navigateToChangePhone = true
                    }
                    
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        
        // 👈 3. Added Navigation Destination for Change Password
        .navigationDestination(isPresented: $navigateToChangePassword) {
            ChangePasswordView(onBack: {
                navigateToChangePassword = false
            })
        }
        .navigationDestination(isPresented: $navigateToChangePhone) {
                    ChangePhoneView()
                }
        
        .sheet(isPresented: $navigateToLanguage) {
            LanguageSelectionView()
                .presentationDetents([.fraction(0.55), .large])
                .presentationCornerRadius(28)
        }
    }
}

// MARK: - Reusable Setting Row Components

/// A row used specifically for boolean toggles
struct SettingsToggleRow: View {
    let iconName: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(Color.secondary.opacity(0.1))
                .clipShape(.rect(cornerRadius: 8))
            
            Text(title.localized())
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 1/255, green: 150/255, blue: 131/255))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        }
    }
}

/// A row used specifically for navigation with an optional trailing value text
struct SettingsNavigationRow: View {
    let iconName: String
    let title: String
    var valueText: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
                
                Text(title.localized())
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if let valueText {
                    Text(valueText.localized())
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(.primary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
