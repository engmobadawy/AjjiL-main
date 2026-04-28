import SwiftUI

enum TopRowButtonMode {
    case justNotification
    case withCartAndNotification
    case filter
    case rate
    case none
}

// MARK: - Main Reusable Component
struct TopRowNotForHome: View {
    let title: String
    var showBackButton: Bool

    var thereIsNoBackButton: Bool {
        return !showBackButton
    }
    
    var cartCount: Int = 0
    var kindOfTopRow: TopRowButtonMode
    
    // Actions
    var onBack: (() -> Void)?
    var onCart: (() -> Void)?
    var onNotification: (() -> Void)?
    var onFilter: (() -> Void)?
    var onRate: (() -> Void)?

    // State Management
    @State private var viewModel = NotificationBadgeViewModel()
    @State private var showGuestLoginSheet: Bool = false
    @State private var navigateToNotifications: Bool = false

    private let iconBackgroundColor = Color(red: 214/255, green: 255/255, blue: 248/255)

    // Helper to intercept actions for guests
    private func handleAction(_ action: (() -> Void)?) {
        if Constants.isGuestMode {
            showGuestLoginSheet = true
        } else {
            action?()
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            
            // MARK: - Back Button
            if showBackButton {
                Button(action: { onBack?() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 42)
                        .contentShape(.circle)
                        .rotationEffect(.degrees(MOLHLanguage.isRTLLanguage() ? 180 : 0))
                }
                .buttonStyle(.plain)
            }

            // MARK: - Title
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 20))
                .lineLimit(1)

            Spacer(minLength: 0)
            
            // MARK: - Action Buttons
            switch kindOfTopRow {
            case .justNotification:
                BadgeIconButton(
                    icon: "bell.fill",
                    isSystemImage: true,
                    count: viewModel.unreadCount, // Dynamically fetched
                    action: {
                        handleAction {
                            navigateToNotifications = true
                            onNotification?()
                        }
                    },
                    offsetX: 8,
                    offsetY: -14
                )
                .frame(width: 42, height: 42)
                .background {
                    Circle()
                        .fill(iconBackgroundColor)
                        .strokeBorder(.white, lineWidth: 1)
                }
                
            case .withCartAndNotification:
                HStack(alignment: .bottom, spacing: 0) {
                    Color.clear.frame(width: 12, height: 12)
                    
                    // MARK: - Cart Button
                    BadgeIconButton(
                        icon: "car",
                        isSystemImage: false,
                        count: cartCount,
                        showBadgeText: false, // <-- ONLY SHOW ORANGE DOT
                        action: { handleAction(onCart) },
                        offsetX: -10,  // <-- Negative X puts the badge on the LEFT
                        offsetY: -14  // <-- Negative Y puts the badge on the TOP
                    )
                    .frame(width: 40, height: 42)
                    
                    // Vertical Separator
                    Rectangle()
                        .fill(.white)
                        .frame(width: 1, height: 24)
                    
                    // MARK: - Bell Button
                    BadgeIconButton(
                        icon: "bell.fill",
                        isSystemImage: true,
                        count: viewModel.unreadCount, // Dynamically fetched
                        action: {
                            handleAction {
                                navigateToNotifications = true
                                onNotification?()
                            }
                        },
                        offsetX: 8,   // <-- Positive X puts the badge on the RIGHT
                        offsetY: -14
                    )
                    .frame(width: 40, height: 42)
                    
                    Color.clear.frame(width: 8, height: 8)
                }
                .background {
                    Capsule()
                        .fill(iconBackgroundColor)
                        .strokeBorder(.white, lineWidth: 1)
                }
                
            case .filter:
                            ActionPillButton(
                                // 🛠️ FIX: Added .newlocalized
                                title: "Filter".newlocalized,
                                iconName: "filter",
                                isSystemImage: false,
                                backgroundColor: iconBackgroundColor,
                                action: { handleAction(onFilter) }
                            )
                            
            case .rate:
                            ActionPillButton(
                                // 🛠️ FIX: Added .newlocalized
                                title: "Rate".newlocalized,
                                iconName: "star.fill",
                                isSystemImage: true,
                                backgroundColor: iconBackgroundColor,
                                action: { handleAction(onRate) }
                            )
            case .none:
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
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
        .sheet(isPresented: $showGuestLoginSheet) {
            GuestLoginSheetView() // Replace with your actual view if different
                .presentationDetents([.fraction(0.5), .medium])
                .presentationDragIndicator(.visible)
                .background(.white)
        }
        .navigationDestination(isPresented: $navigateToNotifications) {
            let networkService = NetworkService()
            let repository = NotificationRepositoryImpl(networkService: networkService)
            let useCase = GetNotificationsUseCase(repository: repository)
            
            NotificationsView(useCase: useCase)
        }
        .task {
            // Only fetch if the mode includes the notification bell
            if kindOfTopRow == .justNotification || kindOfTopRow == .withCartAndNotification {
                await viewModel.fetchUnreadCount()
            }
        }
        .onChange(of: navigateToNotifications) { _, newValue in
            if newValue == false {
                Task {
                    await viewModel.fetchUnreadCount()
                }
            }
        }
    }
}

// MARK: - Reusable Action Pill Button
private struct ActionPillButton: View {
    let title: String
    let iconName: String
    var isSystemImage: Bool
    let backgroundColor: Color
    let action: () -> Void
    
    private let circleColor = Color(red: 238/255, green: 130/255, blue: 40/255)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(title)
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, 4)
                
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 42, height: 42)
                    
                    if isSystemImage {
                        Image(systemName: iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(iconName)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(width: 98, height: 42)
            .background {
                Capsule()
                    .fill(backgroundColor)
                    .strokeBorder(.white, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .contentShape(.capsule)
    }
}

// MARK: - Improved Badge Button (Transparent)
private struct BadgeIconButton: View {
    let icon: String
    var isSystemImage: Bool = true
    let count: Int
    var showBadgeText: Bool = true
    let action: () -> Void
    var offsetImage: CGFloat = 8
    
    var offsetX: CGFloat = 6
    var offsetY: CGFloat = -6
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSystemImage {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.2))
                } else {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color(red: 0.1, green: 0.15, blue: 0.2))
                }
                
                // CONDITIONAL BADGE RENDERING
                if showBadgeText {
                    Text(count < 100 ? count.formatted() : "99")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 14, minHeight: 14)
                        .padding(2)
                        .background(.orange, in: .circle)
                        .offset(x: offsetX, y: offsetY)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    // Exact matching dimensions of the text badge (14 min + 4 total padding = 18x18)
                    Circle()
                        .fill(.orange)
                        .frame(width: 18, height: 18)
                        .offset(x: offsetX, y: offsetY)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .offset(y: offsetImage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
    }
}

// MARK: - Notification Badge View Model
@Observable
@MainActor
final class NotificationBadgeViewModel {
    private(set) var unreadCount: Int = 0
    private let getUnreadCountUseCase: GetUnreadNotificationCountUseCase
    
    init(useCase: GetUnreadNotificationCountUseCase? = nil) {
        if let useCase = useCase {
            self.getUnreadCountUseCase = useCase
        } else {
            // Default dependency injection
            let networkService = NetworkService()
            let repository = NotificationRepositoryImpl(networkService: networkService)
            self.getUnreadCountUseCase = GetUnreadNotificationCountUseCase(repository: repository)
        }
    }
    
    func fetchUnreadCount() async {
        // Prevent unnecessary network calls for guests
        guard !Constants.isGuestMode else {
            self.unreadCount = 0
            return
        }
        
        do {
            let count = try await getUnreadCountUseCase.execute()
            self.unreadCount = count
        } catch {
            print("Failed to fetch unread notification count: \(error)")
        }
    }
}
