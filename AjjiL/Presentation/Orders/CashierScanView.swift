//
//  CashierScanView.swift
//  AjjiLMB
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct CashierScanView: View {
    let orderId: Int
    let qrCode: String
    let points: Int
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Colors matching Figma
    private let titleColor = Color(red: 20/255.0, green: 140/255.0, blue: 90/255.0)
    private let subtitleColor = Color(red: 0, green: 0, blue: 0)
    private let pointsNumberColor = Color(red: 1/255.0, green: 150/255.0, blue: 131/255.0)
    private let pointsTextColor = Color(red: 56/255.0, green: 56/255.0, blue: 56/255.0)
    private let pointsCardBackground = Color(red: 232/255.0, green: 239/255.0, blue: 243/255.0)
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Top Row exactly as requested
            TopRowNotForHome(
                // 🛠️ FIX: Added .newlocalized
                title: "Receive Order".newlocalized,
                showBackButton: true,
                kindOfTopRow: .none,
                onBack: {
                    dismiss()
                }
            )
            
            // Changed spacing to 0 to strictly control the vertical gaps manually
            VStack(spacing: 0) {
                
                // MARK: - Header Text
                VStack(spacing: 12) {
                    // 🛠️ FIX: Added .newlocalized
                    Text("Scane Code".newlocalized)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(titleColor)
                    
                    // 🛠️ FIX: Added .newlocalized
                    Text("Confirm that you are receiving your\norder by scanning the order".newlocalized)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(subtitleColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 40)
                
                // Original gap between text and QR
                Spacer()
                    .frame(height: 48)
                
                // MARK: - Real QR Code Generation
                if let qrImage = generateQRCode(from: qrCode) {
                    Image(uiImage: qrImage)
                        .interpolation(.none) // Keeps the QR code perfectly crisp
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 16))
                        // Optional subtle shadow to lift it off the background
                        .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                } else {
                    // Fallback in case QR generation fails
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 220, height: 220)
                        .overlay {
                            // 🛠️ FIX: Added .newlocalized
                            Text("QR Error".newlocalized)
                        }
                }
                
                // MARK: - Exact 38px Space requested
                Spacer()
                    .frame(height: 38)
                
                // MARK: - Points Card
                HStack(spacing: 16) {
                    Image("points")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 85)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(points)")
                                .font(.system(size: 38, weight: .bold))
                                .foregroundStyle(pointsNumberColor)
                            
                            // 🛠️ FIX: Added .newlocalized
                            Text("Points".newlocalized)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(pointsNumberColor)
                        }
                        
                        // 🛠️ FIX: Added .newlocalized
                        Text("Reward You Gain For Completing The Order".newlocalized)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(pointsTextColor)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 121)
                .frame(maxWidth: .infinity)
                .background(pointsCardBackground)
                .clipShape(.rect(cornerRadius: 18))
                .padding(.horizontal, 24)
                
                // Push everything to the top of the screen so the 38px gap is respected
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - CoreImage QR Generator
    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Convert the string into Data
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // Scale the image up by 10x to ensure it's not blurry when resized in SwiftUI
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
