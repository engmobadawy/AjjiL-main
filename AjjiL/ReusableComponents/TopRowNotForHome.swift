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
    var notificationCount: Int = 0
    var kindOfTopRow: TopRowButtonMode
    
    // Actions
    var onBack: (() -> Void)?
    var onCart: (() -> Void)?
    var onNotification: (() -> Void)?
    var onFilter: (() -> Void)?
    var onRate: (() -> Void)?

    private let iconBackgroundColor = Color(red: 214/255, green: 255/255, blue: 248/255)

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
                Button(action: { onNotification?() }) {
                    // Assuming NotificationBell is defined elsewhere in your project
                    NotificationBell(count: notificationCount)
                }
                
            case .withCartAndNotification:
                HStack(alignment: .bottom, spacing: 0) {
                    Color.clear
                        .frame(width: 12, height: 12)
                    
                    // Cart Button (Custom Asset)
                    BadgeIconButton(
                        icon: "car",
                        isSystemImage: false,
                        count: cartCount,
                        action: { onCart?() },
                        offsetX: -16,
                        offsetY: -14
                    )
                    .frame(width: 40, height: 42)
                    
                    // The Vertical Separator
                    Rectangle()
                        .fill(.white)
                        .frame(width: 1, height: 24)
                    
                    // Bell Button (SF Symbol)
                    BadgeIconButton(
                        icon: "bell.fill",
                        isSystemImage: true,
                        count: notificationCount,
                        action: { onNotification?() },
                        offsetX: 8,
                        offsetY: -14
                    )
                    .frame(width: 40, height: 42)
                    
                    Color.clear
                        .frame(width: 8, height: 8)
                }
                .background {
                    Capsule()
                        .fill(iconBackgroundColor)
                        .strokeBorder(.white, lineWidth: 1)
                }
                
            case .filter:
                ActionPillButton(
                    title: "Filter",
                    iconName: "filter",
                    isSystemImage: false,
                    backgroundColor: iconBackgroundColor,
                    action: { onFilter?() }
                )
                
            case .rate:
                ActionPillButton(
                    title: "Rate",
                    iconName: "star",
                    isSystemImage: true,
                    backgroundColor: iconBackgroundColor,
                    action: { onRate?() }
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
                // Text Area (56px width remaining)
                Text(title)
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, 4)
                
                // Orange Circle Area (42px)
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
        .contentShape(Capsule())
    }
}

// MARK: - Improved Badge Button (Transparent)
private struct BadgeIconButton: View {
    let icon: String
    var isSystemImage: Bool = true
    let count: Int
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
                
                Text(count < 100 ? count.formatted() : "99")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(minWidth: 14, minHeight: 14)
                    .padding(2)
                    .background(.orange, in: .circle)
                    .offset(x: offsetX, y: offsetY)
                    .transition(.scale.combined(with: .opacity))
            }
            .offset(y: offsetImage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        // .buttonStyle(ScaleButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: count)
    }
}
