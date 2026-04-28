import SwiftUI
import Shimmer // 1. Import Shimmer

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
    
    // NEW: State to control the popup visibility
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    
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
                    // 🛠️ FIX: Changed to .newlocalized
                    title: "Profile".newlocalized,
                    showBackButton: false, // Adjusted to false as standard for root tab, but handles the bell internally
                    kindOfTopRow: .justNotification
                )
                
                ScrollView {
                    // 1. Check for Guest Mode
                    if Constants.isGuestMode {
                        guestModeState
                            .padding(.horizontal, 18)
                            .padding(.vertical, 28)
                    } else {
                        VStack(spacing: 15) {
                            
                            if viewModel.isLoading {
                                // 2. Avatar Skeleton + Shimmer
                                ProfileAvatarSkeleton()
                                    .shimmering()
                                
                                // 3. Info Skeleton + Shimmer
                                ProfileInfoSkeleton()
                                    .shimmering()
                                    .padding(.vertical, 4)
                                    
                            } else if let profile = viewModel.profile {
                                // 4. Real Avatar Section
                                Button {
                                    navigateToPersonalData = true
                                } label: {
                                    StoresAvatarView(image: viewModel.profileImage)
                                }
                                .buttonStyle(.plain)
                                
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
                            
                            // Logout Button
                            // 🛠️ FIX: Added .newlocalized
                            WhiteButton(title: "Sign Out".newlocalized, action: {
                                showLogoutConfirmation = true
                            })
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 28)
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .task {
                // Prevent API calls if guest mode
                guard !Constants.isGuestMode else { return }
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
            // Destination: Settings
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
                let networkService = NetworkService()
                let repository = PointRepositoryImp(networkService: networkService)
                let getPointsUC = GetPointsUC(repo: repository)
                let redeemPointsUC = RedeemPointsUC(repo: repository)
                let calcPointsUC = CalcPointsUC(repo: repository)
                
                let viewModel = PointsViewModel(
                    getPointsUC: getPointsUC,
                    redeemPointsUC: redeemPointsUC,
                    calcPointsUC: calcPointsUC
                )
                MyPointsView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToCouponsView) {
                let networkService = NetworkService()
                let repository = CouponsRepositoryImp(networkService: networkService)
                let getCouponsUC = GetCouponsUseCase(repository: repository)
                let viewModel = CouponsViewModel(getCouponsUseCase: getCouponsUC)
                CouponsView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToPromoCodeCardView) {
                let networkService = NetworkService()
                let repository = ProfileRepositoryImp(networkService: networkService)
                let getPromoCodesUC = GetPromoCodesUC(repo: repository)
                let viewModel = PromoCodesViewModel(getPromoCodesUC: getPromoCodesUC)
                PromoCodesView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $navigateToContactUsView) {
                let networkService = NetworkService()
                let repository = ContactRepositoryImp(networkService: networkService)
                let getContactTypesUC = GetContactTypesUseCase(repository: repository)
                let sendContactUsUC = SendContactUsUseCase(repository: repository)
                let viewModel = ContactUsViewModel(
                    getContactTypesUseCase: getContactTypesUC,
                    sendContactUsUseCase: sendContactUsUC
                )
                ContactUsView(viewModel: viewModel)
            }
        }
        // Popup Overlays
        .overlay {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showLogoutConfirmation = false
                    }
                
                LogoutConfirmationPopup(
                    onConfirm: {
                        showLogoutConfirmation = false
                        performLogout()
                    },
                    onCancel: {
                        showLogoutConfirmation = false
                    }
                )
            }
            .opacity(showLogoutConfirmation ? 1 : 0)
            .allowsHitTesting(showLogoutConfirmation)
            .animation(.easeInOut(duration: 0.2), value: showLogoutConfirmation)
        }
        .overlay {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDeleteAccountConfirmation = false
                    }
                
                DeleteAccountConfirmationPopup(
                    onConfirm: {
                        showDeleteAccountConfirmation = false
                    },
                    onCancel: {
                        showDeleteAccountConfirmation = false
                    }
                )
            }
            .opacity(showDeleteAccountConfirmation ? 1 : 0)
            .allowsHitTesting(showDeleteAccountConfirmation)
            .animation(.easeInOut(duration: 0.2), value: showDeleteAccountConfirmation)
        }
    }
}

// MARK: - Guest Mode View

private extension ProfileView {
    @ViewBuilder
    var guestModeState: some View {
        VStack(spacing: 15) {
            // Placeholder Avatar matching the screenshot
            Image(systemName: "person.crop.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 113, height: 113)
                // Appears to be the brand orange
                .foregroundStyle(Color(red: 238/255, green: 130/255, blue: 40/255))
                .padding(.bottom, 8)
            
            // 🛠️ FIX: Changed to .newlocalized
            Text("Welcome".newlocalized)
                .font(.custom("Poppins-Bold", size: 24))
            
            // 🛠️ FIX: Changed to .newlocalized
            Text("Get Your Profile Ready".newlocalized)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            
            // Simplified Menu Section for Guests
            VStack(spacing: 12) {
                ProfileMenuRow(iconName: "gearshape", title: "Setting") {
                    navigateToSettings = true
                }
                ProfileMenuRow(iconName: "info.circle", title: "About Us") {
                    navigateToAboutUsView = true
                }
                ProfileMenuRow(iconName: "phone", title: "Contact Us") {
                    navigateToContactUsView = true
                }
                ProfileMenuRow(iconName: "checkmark.shield", title: "Privacy Policy") {
                    navigateToPrivacyPolicy = true
                }
                ProfileMenuRow(iconName: "ellipsis.message", title: "Terms And Conditions") {
                    navigateToTermsAndConditionView = true
                }
            }
            .padding(.bottom, 24)
            
            // Re-routing button directly to LogIn
            // 🛠️ FIX: Changed to .newlocalized
            GreenButton(title: "SIGN IN".newlocalized) {
                UserDefaults.standard.set(false, forKey: "pressSkip")
                Constants.isGuestMode = false
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.reset()
                }
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Skeleton Loading Views

/// Skeleton mimicking the Avatar Photo and Edit Badge
struct ProfileAvatarSkeleton: View {
    var body: some View {
        Circle()
            .fill(.gray.opacity(0.3))
            .frame(width: 113, height: 113)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 3)
            )
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .offset(x: -12, y: -12)
            }
    }
}

/// Skeleton mimicking the user's name and phone number
struct ProfileInfoSkeleton: View {
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(.gray.opacity(0.3))
                .frame(width: 160, height: 26)
                .clipShape(.rect(cornerRadius: 6))
            
            HStack(spacing: 6) {
                Circle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 14, height: 14)
                
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 110, height: 18)
                    .clipShape(.rect(cornerRadius: 4))
            }
        }
    }
}

// MARK: - Subviews & Actions
private extension ProfileView {
    
    func performLogout() {
        GenericUserDefault.shared.removeValue(Constants.shared.token)
        MOLH.reset()
    }
    
    @ViewBuilder
    private func errorStateView(message: String) -> some View {
        VStack(spacing: 12) {
            // 🛠️ FIX: Changed to .newlocalized
            Text("welcome".newlocalized)
                .font(.custom("Poppins-Bold", size: 24))
            
            // 🛠️ FIX: Changed to .newlocalized
            Text("get_profile_ready".newlocalized)
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
                
                // 🛠️ FIX: Changed to .newlocalized
                Text("QR Profile Code".newlocalized)
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
                tabRouter.selectedTab = 1
            }
            
            ProfileMenuRow(iconName: "gift", title: "My Points") {
                navigateToMyPointsView = true
            }
            
            ProfileMenuRow(iconName: "percent", title: "Coupons") {
                navigateToCouponsView = true
            }
            
            ProfileMenuRow(iconName: "ticket", title: "Promo Code") {
                navigateToPromoCodeCardView = true
            }
            
            ProfileMenuRow(iconName: "gearshape", title: "Settings") {
                navigateToSettings = true
            }
            
            ProfileMenuRow(iconName: "phone", title: "Contact Us") {
                navigateToContactUsView = true
            }
            
            ProfileMenuRow(iconName: "info.circle", title: "About Us") {
                navigateToAboutUsView = true
            }
            
            ProfileMenuRow(iconName: "checkmark.shield", title: "Privacy Policy") {
                navigateToPrivacyPolicy = true
            }
            
            ProfileMenuRow(iconName: "ellipsis.message", title: "Terms & Conditions") {
                navigateToTermsAndConditionView = true
            }
            
            ProfileMenuRow(iconName: "trash", title: "Delete Account") {
                showDeleteAccountConfirmation = true
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
                
                // 🛠️ FIX: Changed to .newlocalized
                Text(title.newlocalized)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(MOLHLanguage.isRTLLanguage() ? 180 : 0))
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

// MARK: - Logout Confirmation Popup Component
struct LogoutConfirmationPopup: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    private let themeGreen = Color(red: 68/255, green: 146/255, blue: 130/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // 🛠️ FIX: Changed to .newlocalized
            Text("Do You Want To Logout?".newlocalized)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundStyle(themeGreen)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button(action: onConfirm) {
                    // 🛠️ FIX: Changed to .newlocalized
                    Text("Yes".newlocalized)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(themeGreen)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                Button(action: onCancel) {
                    // 🛠️ FIX: Changed to .newlocalized
                    Text("Cancel".newlocalized)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(white: 0.94))
                        .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.horizontal, 32)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}


// MARK: - Settings View


struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Persistent state using AppStorage
    @AppStorage("isPushNotificationEnabled") private var isPushNotificationEnabled: Bool = true
    
    @State private var navigateToLanguage: Bool = false
    @State private var navigateToChangePassword: Bool = false
    @State private var navigateToChangePhone: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            TopRowNotForHome(
                title: "Settings".newlocalized,
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            ScrollView {
                VStack(spacing: 16) {
                    SettingsToggleRow(
                        iconName: "bell",
                        title: "Push Notification",
                        isOn: $isPushNotificationEnabled
                    )
                    // Modern iOS 17+ onChange modifier
                    .onChange(of: isPushNotificationEnabled) { oldValue, newValue in
                        Task {
                            await updateBackendNotificationPreference(isEnabled: newValue, oldValue: oldValue)
                        }
                    }
                    
                    SettingsNavigationRow(
                        iconName: "globe",
                        title: "Language",
                        valueText: "English"
                    ) {
                        navigateToLanguage = true
                    }
                    
                    // Conditionally hide Change Password & Phone if guest mode
                    if !Constants.isGuestMode {
                        SettingsNavigationRow(
                            iconName: "lock",
                            title: "Change Password"
                        ) {
                            navigateToChangePassword = true
                        }
                        
                        SettingsNavigationRow(
                            iconName: "phone",
                            title: "Change Phone Number"
                        ) {
                            navigateToChangePhone = true
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
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
    
    // MARK: - Backend Integration Helpers
    
    private func updateBackendNotificationPreference(isEnabled: Bool, oldValue: Bool) async {
        // 1. Optional System Verification
        if isEnabled {
            let hasPermission = await checkSystemNotificationPermission()
            if !hasPermission {
                print("⚠️ User toggled ON, but system notification permissions are denied in iOS Settings.")
                // To do: Show an alert instructing the user to open iOS Settings
            }
        }
        
        print("🌐 Syncing push notification preference to backend: \(isEnabled)")
        
       
        

        
    }
    
    private func checkSystemNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }
}

// MARK: - Reusable Setting Row Components

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
            
            // 🛠️ FIX: Changed to .newlocalized
            Text(title.newlocalized)
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
                
                // 🛠️ FIX: Changed to .newlocalized
                Text(title.newlocalized)
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if let valueText {
                    // 🛠️ FIX: Changed to .newlocalized
                    Text(valueText.newlocalized)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundStyle(.primary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(MOLHLanguage.isRTLLanguage() ? 180 : 0))
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

struct DeleteAccountConfirmationPopup: View {
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    private let themeGreen = Color(red: 68/255, green: 146/255, blue: 130/255)
    private let deleteRed = Color(red: 232/255, green: 59/255, blue: 46/255)
    
    var body: some View {
        VStack(spacing: 24) {
            // 🛠️ FIX: Changed to .newlocalized
            Text("Do You Want To Delete\nYour Account?".newlocalized)
                .font(.custom("Poppins-Bold", size: 22))
                .foregroundStyle(themeGreen)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button(action: onConfirm) {
                    // 🛠️ FIX: Changed to .newlocalized
                    Text("Yes, Delete".newlocalized)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(deleteRed)
                        .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                Button(action: onCancel) {
                    // 🛠️ FIX: Changed to .newlocalized
                    Text("Cancel".newlocalized)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(white: 0.94))
                        .clipShape(.rect(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(24)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.horizontal, 32)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}
