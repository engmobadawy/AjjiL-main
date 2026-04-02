import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var navigateToPersonalData = false
    @State private var navigateToLanguage = false // 👈 Added state for language navigation
    
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
            // Existing Destination: Personal Data
            .navigationDestination(isPresented: $navigateToPersonalData) {
                // Dependency Injection for PersonalDataView
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
         
            .sheet(isPresented: $navigateToLanguage) {
                LanguageSelectionView()
                    .presentationDetents([.fraction(0.55), .large])
                    .presentationCornerRadius(28) 
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
            .background(Color.brandGreen)
            .clipShape(.rect(cornerRadius: 12))
        }
    }
    
    // MARK: - Menu List Section
    var menuSection: some View {
        VStack(spacing: 12) {
            ProfileMenuRow(iconName: "bag", title: "My Orders") {
                // Navigate to My Orders
            }
            
            ProfileMenuRow(iconName: "gift", title: "My Points") {
                // Navigate to My Points
            }
            
            ProfileMenuRow(iconName: "percent", title: "Coupons") {
                // Navigate to Coupons
            }
            
            ProfileMenuRow(iconName: "ticket", title: "Promo Code") {
                // Navigate to Promo Code
            }
            
            ProfileMenuRow(iconName: "gearshape", title: "Settings") {
                // Navigate to Settings
            }
            
            // 👈 New Language Row Added Here
            ProfileMenuRow(iconName: "globe", title: "Language") {
                navigateToLanguage = true
            }
            
            ProfileMenuRow(iconName: "phone", title: "Contact Us") {
                // Navigate to Contact Us
            }
            
            ProfileMenuRow(iconName: "info.circle", title: "About Us") {
                // Navigate to About Us
            }
            
            ProfileMenuRow(iconName: "checkmark.shield", title: "Privacy Policy") {
                // Navigate to Privacy Policy
            }
            
            ProfileMenuRow(iconName: "ellipsis.message", title: "Terms & Conditions") {
                // Navigate to Terms & Conditions
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
                // Left Icon
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 8))
                
                // Title
                Text(title.localized())
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Right Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .clipShape(.rect(cornerRadius: 12))
            .overlay {
                // Subtle border matching the design
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            }
        }
        .buttonStyle(.plain) // Prevents the whole row from flashing the default accent color on tap
    }
}
