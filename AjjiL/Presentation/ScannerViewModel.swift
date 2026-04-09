//
//  ScannerViewModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 11/03/2026.
//


import SwiftUI
import Observation
import VisionKit

// MARK: - View Model
@Observable
@MainActor
final class ScannerViewModel {
   
    var manualInput: String = ""
    var scannedBarcode: String? = nil
    
    func submitManualInput() {
        guard !manualInput.isEmpty else { return }
        processBarcode(manualInput)
    }
    
    func processBarcode(_ code: String) {
        print("Barcode processed: \(code)")
        // TODO: Add routing or API logic here
    }
}

// MARK: - Main View
struct ScannerMainView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ScannerViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Mocking the TopRow from your screenshot
            TopRowNotForHome(title: "Scan", showBackButton: true, kindOfTopRow: .justNotification , onBack: {
                dismiss()
            })
            
            ManualEntrySection(viewModel: viewModel)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
            
            ScannerCameraSection(viewModel: viewModel)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }.navigationBarBackButtonHidden(true)
    }
}

//// MARK: - Subviews
//struct TopRowView: View {
//    var body: some View {
//        HStack {
//            Button(action: { /* dismiss */ }) {
//                Image(systemName: "arrow.left")
//                    .font(.title2.bold())
//                    .foregroundStyle(.black)
//            }
//            Text("Scan")
//                .font(.title2.bold())
//            
//            Spacer()
//            
//            Image(systemName: "bell.fill")
//                .padding(10)
//                .background(Color.white)
//                .clipShape(.circle)
//                .overlay(alignment: .topTrailing) {
//                    Circle()
//                        .fill(Color.orange)
//                        .frame(width: 10, height: 10)
//                        .offset(x: -2, y: 2)
//                }
//        }
//        .padding(.horizontal)
//        .padding(.top, 10)
//        .padding(.bottom, 20)
//        .background(Color(red: 0.85, green: 0.98, blue: 0.95)) // Light mint background
//    }
//}

struct ManualEntrySection: View {
    @Bindable var viewModel: ScannerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Can't scan the barcode, Type the ID.")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                TextField("Product Barcode", text: $viewModel.manualInput)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(.rect(cornerRadius: 12))
                    .keyboardType(.asciiCapableNumberPad)
                
                Button(action: viewModel.submitManualInput) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.teal)
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }
}

struct ScannerCameraSection: View {
    @Bindable var viewModel: ScannerViewModel
    
    var body: some View {
        ZStack {
            Color.black
            
            // Safety check for Simulator / Preview support
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                VisionBarcodeScanner(scannedCode: $viewModel.scannedBarcode)
            } else {
                VStack {
                    Image(systemName: "camera.viewfinder")
                        .font(.largeTitle)
                    Text("Camera not available in Simulator")
                        .font(.caption)
                }
                .foregroundStyle(.white.opacity(0.5))
            }
            
            ScannerOverlay()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: viewModel.scannedBarcode) { _, newValue in
            if let code = newValue {
                viewModel.processBarcode(code)
            }
        }
    }
}

struct ScannerOverlay: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.red.opacity(0.15))
                .aspectRatio(1, contentMode: .fit)
                .padding(40)
            
            GeometryReader { geometry in
                let scanArea = geometry.size.width - 80
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: scanArea, height: 2)
                    .offset(y: isAnimating ? (scanArea / 2) : -(scanArea / 2))
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            isAnimating = true
        }
    }
}

// MARK: - VisionKit Wrapper
struct VisionBarcodeScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let viewController = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .fast,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isHighlightingEnabled: false
        )
        viewController.delegate = context.coordinator
        try? viewController.startScanning()
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: VisionBarcodeScanner
        
        init(_ parent: VisionBarcodeScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = addedItems.first else { return }
            
            if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
                Task { @MainActor in
                    parent.scannedCode = payload
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScannerMainView()
}
