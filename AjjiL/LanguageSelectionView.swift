import SwiftUI

struct LanguageSelectionView: View {
    @State private var selectedLanguage: LanguagesEnum = .english
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator has been removed
            
            // Large Title
            HStack {
                Text("Application Languages".localized())
                    .font(.custom("Poppins-Bold", size: 24))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 32) // Added top padding so it doesn't hug the very top of the screen
            .padding(.bottom, 24)
            
            // Content
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(LanguagesEnum.allCases.filter { $0 != .none }) { language in
                        LanguageOptionRow(
                            languageName: language.name,
                            flagImage: Image(language.image),
                            isSelected: selectedLanguage == language
                        ) {
                            selectedLanguage = language
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            
            // Confirm Button
            Button {
                confirmLanguageChange()
            } label: {
                Text("Confirm".localized())
                    .font(.custom("Poppins-SemiBold", size: 18))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(red: 83/255, green: 155/255, blue: 137/255))
                    .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
       
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            selectedLanguage = LanguagesEnum.current
        }
    }
    
    private func confirmLanguageChange() {
        let languageCode = selectedLanguage.languageCode
        
        if Constants.shared.isAR, languageCode == "en" {
            UserDefaults.standard.set(true, forKey: Constants.shared.resetLanguage)
            MOLH.setLanguageTo("en")
            MOLH.reset()
        } else if !Constants.shared.isAR, languageCode == "ar" {
            UserDefaults.standard.set(true, forKey: Constants.shared.resetLanguage)
            MOLH.setLanguageTo("ar")
            MOLH.reset()
        } else {
            dismiss()
        }
    }
}

// MARK: - Row Component
struct LanguageOptionRow: View {
    let languageName: String
    let flagImage: Image
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag Image
                flagImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(.circle)
                
                // Language Name
                Text(languageName)
                    .font(.custom("Poppins-Medium", size: 18))
                    .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .light))
                        .foregroundStyle(Color.orange)
                }
            }
            .padding(16)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .background(.white, in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.orange : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: isSelected ? 1.5 : 1)
        }
    }
}

// MARK: - Enum
enum LanguagesEnum: String, CaseIterable, Identifiable {
    case english
    case arabic
    case none
    
    var id: String { return self.rawValue }
    
    var name: String {
        switch self {
        case .english: return "English"
        case .arabic: return "عربي"
        case .none: return ""
        }
    }
    
    var image: ImageResource {
        switch self {
        case .english: return .english
        case .arabic: return .arabic
        case .none: return .english
        }
    }
    
    var languageCode: String {
        switch self {
        case .english: return "en"
        case .arabic: return "ar"
        case .none: return ""
        }
    }
    
    static var current: LanguagesEnum {
        let currentLang = MOLHLanguage.currentAppleLanguage()
        return currentLang == "ar" ? .arabic : .english
    }
}
