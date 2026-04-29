//
//  CashierScanView.swift
//  AjjiLMB
//

import SwiftUI

struct CashierScanView: View {
    let orderId: Int
    let qrCode: String
    let points: Int
    
    var body: some View {
        VStack(spacing: 32) {
            
            VStack(spacing: 8) {
                Text("Order #\(orderId)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("Present this code to the cashier")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Rectangle()
                .fill(Color.white)
                .frame(width: 280, height: 280)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 15, y: 5)
                .overlay {
                    VStack(spacing: 16) {
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .padding(40)
                            .foregroundStyle(Color(red: 0.16, green: 0.53, blue: 0.38))
                        
                        Text(qrCode)
                            .font(.title)
                            .fontDesign(.monospaced)
                            .foregroundStyle(.primary)
                    }
                }
            
            HStack(spacing: 8) {
                Image(systemName: "star.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                Text("Points earned: \(points)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.orange.opacity(0.15))
            .clipShape(.capsule)
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationTitle("Cashier Scan")
        .navigationBarTitleDisplayMode(.inline)
    }
}