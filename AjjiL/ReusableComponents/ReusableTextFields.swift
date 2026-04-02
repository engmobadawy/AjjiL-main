import SwiftUI


struct CustomTextField: View {
    // Validation Props
    var isValid: Bool = true
    var errorMessage: String? = nil

    @Binding var text: String

    // Appearance
    let placeholder: String
    var icon: Image? = nil
    var backgroundColor: Color = .goodGray
    var strokeColor: Color? = nil

    // Configuration
    var preset: TextInputPreset = .username
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        // logic for colors
        let activeBorderColor: Color? = !isValid ? .red : strokeColor
        let activeBackgroundColor: Color = !isValid ? Color.red.opacity(0.1) : backgroundColor

        VStack(alignment: .leading, spacing: 6) {
            
            HStack(spacing: 12) {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }

                
                if #available(iOS 26.0, *) {
                                    TextField(placeholder, text: $text)
                        .textInputPreset(preset)
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onSubmit { onSubmit?() }
                                           
                                            .multilineTextAlignment(strategy: .layoutBased)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                           
                                    } else {
                                        TextField("", text: $text)
                                            .textInputPreset(preset)
                                            .font(.system(size: 18))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .onSubmit { onSubmit?() }
                                                               
                                           
                                            .textFieldStyle(PlainTextFieldStyle())
                                         
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                    
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(activeBackgroundColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                if let activeBorderColor {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(activeBorderColor, lineWidth: 2)
                }
            }
            
            // Error Message
            if let errorMessage, !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}



struct SecureCustomTextField: View {
    // Validation Props
    var isValid: Bool = true
    var errorMessage: String? = nil
    
    @Binding var text: String
    var placeholder: String
    
    // Appearance
    var backgroundColor: Color = .goodGray
    var strokeColor: Color? = nil
    
    // Behavior
    var preset: TextInputPreset = .password
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @State private var isRevealed = false
    @FocusState private var isFocused: Bool

    var body: some View {
        // logic for colors
        let activeBorderColor: Color? = !isValid ? .red : strokeColor
        let activeBackgroundColor: Color = !isValid ? Color.red.opacity(0.1) : backgroundColor

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.secondary)
                
                Group {
                    if #available(iOS 26.0, *) {
                        Group {
                            if isRevealed {
                                TextField(placeholder, text: $text)
                            } else {
                                SecureField(placeholder, text: $text)
                            }
                        }
                        .multilineTextAlignment(strategy: .layoutBased)
                    } else {
                        Group {
                            if isRevealed {
                                // Using empty string as provided in your fallback example
                                TextField("", text: $text)
                            } else {
                                SecureField("", text: $text)
                            }
                        }
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.leading)
                    }
                }
                .textInputPreset(preset)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .focused($isFocused)
                .submitLabel(submitLabel)
                .onSubmit { onSubmit?() }
                
                Button {
                    isRevealed.toggle()
                    isFocused = true
                } label: {
                    Image(systemName: isRevealed ? "eye" : "eye.slash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.secondary)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(activeBackgroundColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                if let activeBorderColor {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(activeBorderColor, lineWidth: 2)
                }
            }

            // Error Message
            if let errorMessage, !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}





struct PhoneTextField: View {
    // 1. Capture the app's actual layout direction before the HStack overrides it
    @Environment(\.layoutDirection) private var appLayoutDirection
  
    // Validation Props
    var isValid: Bool = true
    var errorMessage: String?
    
    @Binding var text: String

    // Content
    var placeholder: String = "Phone Number".localized()
    var countryCode: String = "+966"

    // Images (SwiftUI)
    var flagImage: Image = Image("flag")
    var phoneIcon: Image = Image("Call")
    var chevronImage: Image = Image(systemName: "chevron.down")

    // Style
    var backgroundColor: Color = Color(.systemGray6)
    var strokeColor: Color? = nil
    var strokeWidth: CGFloat = 2
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 56

    var iconTint: Color = .secondary
    var separatorColor: Color = .secondary.opacity(0.25)

    // Behavior (SwiftUI-friendly)
    var preset: TextInputPreset = .phone
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)? = nil

    var body: some View {
        // logic for colors
        let activeBorderColor: Color? = !isValid ? .red : strokeColor
        let activeBackgroundColor: Color = !isValid ? Color.red.opacity(0.1) : backgroundColor

        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                flagImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 20)
                    .accessibilityHidden(true)
                
                chevronImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(iconTint)
                    .accessibilityHidden(true)
                
                Text(countryCode)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                
                Rectangle()
                    .fill(separatorColor)
                    .frame(width: 1, height: 24)
                    .accessibilityHidden(true)
                
                if #available(iOS 26.0, *) {
                    TextField(placeholder, text: $text)
                        .textInputPreset(preset)
                        .font(.system(size: 18))
                        .onSubmit { onSubmit?() }
                        .multilineTextAlignment(strategy: .layoutBased)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // 2. Give the TextField back the app's real layout direction
                        .environment(\.layoutDirection, appLayoutDirection)
                } else {
                    TextField("", text: $text)
                        .textInputPreset(preset)
                        .font(.system(size: 18))
                        .onSubmit { onSubmit?() }
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        // 2. Give the TextField back the app's real layout direction
                        .environment(\.layoutDirection, appLayoutDirection)
                }
                
                phoneIcon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(iconTint)
                    .accessibilityHidden(true)
            }
            // 3. Keep the overall HStack strictly Left-to-Right
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 16)
            .frame(height: height)
            .background(activeBackgroundColor, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                if let activeBorderColor {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(activeBorderColor, lineWidth: strokeWidth)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(placeholder))
            .accessibilityValue(Text("\(countryCode) \(text)"))
            
            // Error Message
            if let errorMessage, !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
        }
        .animation(.easeInOut(duration: 0.2), value: isValid)
    }
}



