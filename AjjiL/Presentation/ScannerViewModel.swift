
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





////
////  ScannerViewModel.swift
////  AjjiL
////
////  Created by mohamed mahmoud sobhy badawy on 11/03/2026.
////
//
//
//import SwiftUI
//import Observation
//import VisionKit
//
//// MARK: - View Model
//@Observable
//@MainActor
//final class ScannerViewModel {
//    var manualInput: String = ""
//    var scannedBarcode: String? = nil
//    
//    // Evaluation State
//    var targetProduct: HomeFeaturedProductDataEntity?
//    var currentStatus: ScanStatus? = nil
//    var showResultSheet: Bool = false
//    
//    // Closure to communicate back to the StoreViewModel
//    var onAddToCart: ((HomeFeaturedProductDataEntity) async -> Void)?
//    
//    func submitManualInput() {
//        guard !manualInput.isEmpty else { return }
//        processBarcode(manualInput)
//        manualInput = "" // Clear input after submission
//    }
//    
//    func processBarcode(_ code: String) {
//        guard let product = targetProduct else { return }
//        
//        let cleanedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
//        // Match backend logic: if barcode is empty, it uses the ID
//        let expectedBarcode = product.barcode.isEmpty ? String(product.id) : product.barcode
//        
//        if cleanedCode == expectedBarcode {
//            // Match Success!
//            Task {
//                await onAddToCart?(product)
//                self.currentStatus = .success
//                self.showResultSheet = true
//            }
//        } else {
//            // Match Failed!
//            self.currentStatus = .failure
//            self.showResultSheet = true
//        }
//    }
//}
//
//// MARK: - Main View
//struct ScannerMainView: View {
//    let product: HomeFeaturedProductDataEntity
//    let onAddToCart: (HomeFeaturedProductDataEntity) async -> Void
//    
//    var onGoToCart: () -> Void
//    var onGoToStore: () -> Void // 🛠️ NEW: Added closure for Store Routing
//    
//    @Environment(\.dismiss) private var dismiss
//    @State private var viewModel = ScannerViewModel()
//    
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                TopRowNotForHome(
//                    title: "Scan",
//                    showBackButton: true,
//                    kindOfTopRow: .justNotification,
//                    onBack: { dismiss() }
//                )
//                
//                ManualEntrySection(viewModel: viewModel)
//                    .padding(.vertical, 24)
//                    .padding(.horizontal, 20)
//                
//                ScannerCameraSection(viewModel: viewModel)
//            }
//            
//            // Custom Popup Overlay
//            if viewModel.showResultSheet, let status = viewModel.currentStatus {
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea()
//                    .onTapGesture { viewModel.showResultSheet = false }
//                
//                ScanResultSheet(
//                    status: status,
//                    onClose: { viewModel.showResultSheet = false },
//                    onPrimaryAction: {
//                        viewModel.showResultSheet = false
//                        
//                        if status == .success {
//                            // Go To Cart (Success)
//                            dismiss()
//                            onGoToCart()
//                        } else {
//                            // Try Again (Failure)
//                            viewModel.scannedBarcode = nil
//                        }
//                    },
//                    onSecondaryAction: {
//                        // Back To Store (Both Success & Failure)
//                        viewModel.showResultSheet = false
//                        dismiss() // Closes Scanner
//                        onGoToStore() // Triggers Store Routing
//                    }
//                )
//                .transition(.scale.combined(with: .opacity))
//                .zIndex(2)
//            }
//        }
//        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.showResultSheet)
//        .onAppear {
//            viewModel.targetProduct = product
//            viewModel.onAddToCart = onAddToCart
//        }
//        .onTapGesture {
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}
//
//
//             
//
//
//struct ManualEntrySection: View {
//    @Bindable var viewModel: ScannerViewModel
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Can't scan the barcode, Type the ID.")
//                .font(.headline)
//                .foregroundStyle(.secondary)
//            
//            HStack(spacing: 12) {
//                TextField("Product Barcode", text: $viewModel.manualInput)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .clipShape(.rect(cornerRadius: 12))
//                    .keyboardType(.asciiCapableNumberPad)
//                
//                Button(action: viewModel.submitManualInput) {
//                    Image(systemName: "arrow.right")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundStyle(.white)
//                        .frame(width: 56, height: 56)
//                        .background(Color.teal)
//                        .clipShape(.rect(cornerRadius: 12))
//                }
//            }
//        }
//    }
//}
//
//struct ScannerCameraSection: View {
//    @Bindable var viewModel: ScannerViewModel
//    
//    var body: some View {
//        ZStack {
//            Color.black
//            
//            // Safety check for Simulator / Preview support
//            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
//                VisionBarcodeScanner(scannedCode: $viewModel.scannedBarcode)
//            } else {
//                VStack {
//                    Image(systemName: "camera.viewfinder")
//                        .font(.largeTitle)
//                    Text("Camera not available in Simulator")
//                        .font(.caption)
//                }
//                .foregroundStyle(.white.opacity(0.5))
//            }
//            
//            ScannerOverlay()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .ignoresSafeArea(edges: .bottom)
//        .onChange(of: viewModel.scannedBarcode) { _, newValue in
//            if let code = newValue {
//                viewModel.processBarcode(code)
//            }
//        }
//    }
//}
//
//struct ScannerOverlay: View {
//    @State private var isAnimating = false
//    
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.red.opacity(0.15))
//                .aspectRatio(1, contentMode: .fit)
//                .padding(40)
//            
//            GeometryReader { geometry in
//                let scanArea = geometry.size.width - 80
//                
//                Rectangle()
//                    .fill(Color.red)
//                    .frame(width: scanArea, height: 2)
//                    .offset(y: isAnimating ? (scanArea / 2) : -(scanArea / 2))
//                    .animation(
//                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
//                        value: isAnimating
//                    )
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
//        }
//        .task {
//            isAnimating = true
//        }
//    }
//}
//
//// MARK: - VisionKit Wrapper
//struct VisionBarcodeScanner: UIViewControllerRepresentable {
//    @Binding var scannedCode: String?
//    
//    func makeUIViewController(context: Context) -> DataScannerViewController {
//        let viewController = DataScannerViewController(
//            recognizedDataTypes: [.barcode()],
//            qualityLevel: .fast,
//            recognizesMultipleItems: false,
//            isHighFrameRateTrackingEnabled: true,
//            isHighlightingEnabled: false
//        )
//        viewController.delegate = context.coordinator
//        try? viewController.startScanning()
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) { }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, DataScannerViewControllerDelegate {
//        var parent: VisionBarcodeScanner
//        
//        init(_ parent: VisionBarcodeScanner) {
//            self.parent = parent
//        }
//        
//        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
//            guard let item = addedItems.first else { return }
//            
//            if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
//                Task { @MainActor in
//                    parent.scannedCode = payload
//                }
//            }
//        }
//    }
//}
//
//
//
//
//
//
//import SwiftUI
//
//// MARK: - State Model
//enum ScanStatus {
//    case success
//    case failure
//    
//    var imageName: String {
//        self == .success ? "done" : "notdone"
//    }
//    
//    var title: String {
//        self == .success ? "Scann Success" : "Not Match"
//    }
//    
//    var titleColor: Color {
//        self == .success ? Color(red: 1/255, green: 150/255, blue: 131/255) : Color(red: 255/255, green: 64/255, blue: 64/255)
//    }
//    
//    var subtitle: String? {
//        self == .success ? nil : "Check the validity of the branch or product."
//    }
//    
//    var primaryButtonText: String {
//        self == .success ? "Go To Cart" : "Try Again"
//    }
//    
//    var secondaryButtonText: String {
//        self == .success ? "Back To Store" : "Back To Store"
//    }
//}
//
//// MARK: - Main View
//struct ScanResultSheet: View {
//    let status: ScanStatus
//    
//    // Action handlers (pass your methods in here)
//    var onClose: () -> Void
//    var onPrimaryAction: () -> Void
//    var onSecondaryAction: () -> Void
//    
//    var body: some View {
//        VStack(spacing: 24) {
//            closeButtonHeader
//            
//            imageSection
//            
//            textSection
//            
//            VStack(spacing: 20) {
//                primaryActionButton
//                secondaryActionButton
//            }
//            .padding(.top, 10)
//        }
//        .padding(24)
//        .background(.white)
//        .clipShape(.rect(cornerRadius: 24))
//        // Frame to keep it looking like the popup in the design
//        .frame(maxWidth: 400)
//        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
//    }
//}
//
//// MARK: - View Components
//private extension ScanResultSheet {
//    
//    var closeButtonHeader: some View {
//        HStack {
//            Spacer()
//            Button(action: onClose) {
//                Image(systemName: "xmark")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundStyle(.gray)
//                    .padding(8)
//                    .background {
//                        Circle()
//                            .strokeBorder(.gray.opacity(0.5), lineWidth: 1)
//                    }
//            }
//        }
//    }
//    
//    var imageSection: some View {
//        Image(status.imageName)
//            .resizable()
//            .scaledToFit()
//            .frame(width: 252, height: 137)
//    }
//    
//    var textSection: some View {
//        VStack(spacing: 12) {
//            Text(status.title)
//                .font(.custom("Poppins-SemiBold", size: 28))
//                .foregroundStyle(status.titleColor)
//            
//            if let subtitle = status.subtitle {
//                Text(subtitle)
//                    .font(.custom("Poppins-Regular", size: 16))
//                    .foregroundStyle(Color(red: 0, green: 0, blue: 0))
//                    .multilineTextAlignment(.center)
//            }
//        }
//    }
//    
//    var primaryActionButton: some View {
//        Button(action: onPrimaryAction) {
//            Text(status.primaryButtonText)
//                .font(.custom("Poppins-Medium", size: 16))
//                .foregroundStyle(.white)
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, 16)
//                .background {
//                    // Teal button background from the image
//                    Color(red: 69/255, green: 154/255, blue: 139/255)
//                        .clipShape(.rect(cornerRadius: 12))
//                }
//        }
//    }
//    
//    var secondaryActionButton: some View {
//        Button(action: onSecondaryAction) {
//            Text(status.secondaryButtonText)
//                .font(.custom("Poppins-Medium", size: 18))
//                // rgba(255, 119, 1, 1)
//                .foregroundStyle(Color(red: 255/255, green: 119/255, blue: 1/255))
//                .underline()
//        }
//    }
//}
//
//
//
//#Preview{
//    ScanResultSheet(status: .failure, onClose: {}, onPrimaryAction: {}, onSecondaryAction: {})
//}
