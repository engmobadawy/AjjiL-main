import Foundation
import Observation
import SwiftUI
import WebKit

// MARK: - 1. Network DTOs (What the API sends)
struct SubmitOrderModel: Codable {
    let status: Bool?
    let message: String?
    let data: SubmitOrderDataDTO?
}

struct SubmitOrderDataDTO: Codable {
    let orderId: Int?
    let paymentLink: String?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paymentLink = "payment_link"
    }
}

// MARK: - 2. Domain Entity (What your UI uses)
// Flattened for easier use in your ViewModel
struct SubmitOrderEntity: Hashable {
    let status: Bool
    let message: String
    let orderId: Int
    let paymentLink: String
}

// MARK: - 3. Mapper (The Bridge)
extension SubmitOrderModel {
    func map() -> SubmitOrderEntity {
        return SubmitOrderEntity(
            status: self.status ?? false,
            message: self.message ?? "Unknown error",
            orderId: self.data?.orderId ?? 0,
            paymentLink: self.data?.paymentLink ?? ""
        )
    }
}

// MARK: - 4. View Models & Helpers

struct PaymentDestination: Identifiable {
    let id = UUID()
    let url: URL
}
//
//@Observable
//@MainActor
//final class CheckoutViewModel {
//    private let submitOrderUC: SubmitOrderUC
//    
//    // View State
//    var isLoading = false
//    var errorMessage: String?
//    var paymentDestination: PaymentDestination?
//    
//    init(submitOrderUC: SubmitOrderUC) {
//        self.submitOrderUC = submitOrderUC
//    }
//    
//    func confirmPayment(cartId: String, storeId: String, branchId: String, paymentMethod: String, couponCode: String? = nil) async {
//        isLoading = true
//        errorMessage = nil
//        
//        do {
//            let response = try await submitOrderUC.execute(
//                cartId: cartId,
//                storeId: storeId,
//                branchId: branchId,
//                paymentMethod: paymentMethod,
//                couponCode: couponCode
//            )
//            
//            // Because we flattened the entity, accessing paymentLink is clean and direct
//            if response.status, let url = URL(string: response.paymentLink), !response.paymentLink.isEmpty {
//                paymentDestination = PaymentDestination(url: url)
//            } else {
//                errorMessage = response.message
//            }
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        
//        isLoading = false
//    }
//}
//
//// MARK: - 5. Views
//
//struct WebView: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        return WKWebView()
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        let request = URLRequest(url: url)
//        uiView.load(request)
//    }
//}
//
//struct CheckoutView: View {
//    @State private var viewModel: CheckoutViewModel
//    
//    // Dummy data mimicking your Postman test
//    private let cartId = "358"
//    private let storeId = "4"
//    private let branchId = "4"
//    private let paymentMethod = "3"
//    private let couponCode = "noo"
//
//    init(viewModel: CheckoutViewModel) {
//        self._viewModel = State(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 20) {
//                Spacer()
//                
//                PaymentStatusText(errorMessage: viewModel.errorMessage)
//                
//                ConfirmPaymentButton(
//                    isLoading: viewModel.isLoading,
//                    action: handleConfirmPayment
//                )
//            }
//            .padding()
//            .navigationTitle("Checkout")
//            .sheet(item: $viewModel.paymentDestination) { destination in
//                PaymentGatewaySheet(destination: destination)
//            }
//        }
//    }
//    
//    private func handleConfirmPayment() {
//        Task {
//            await viewModel.confirmPayment(
//                cartId: cartId,
//                storeId: storeId,
//                branchId: branchId,
//                paymentMethod: paymentMethod,
//                couponCode: couponCode
//            )
//        }
//    }
//}
//
//struct ConfirmPaymentButton: View {
//    let isLoading: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            if isLoading {
//                ProgressView()
//            } else {
//                Text("Confirm Payment")
//                    .frame(maxWidth: .infinity)
//            }
//        }
//        .buttonStyle(.borderedProminent)
//        .controlSize(.large)
//        .disabled(isLoading)
//    }
//}
//
//struct PaymentStatusText: View {
//    let errorMessage: String?
//    
//    var body: some View {
//        if let errorMessage {
//            Text(errorMessage)
//                .foregroundStyle(.red)
//                .multilineTextAlignment(.center)
//        }
//    }
//}
//
//struct PaymentGatewaySheet: View {
//    @Environment(\.dismiss) private var dismiss
//    let destination: PaymentDestination
//    
//    var body: some View {
//        NavigationStack {
//            WebView(url: destination.url)
//                .navigationTitle("Secure Payment")
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .cancellationAction) {
//                        Button("Cancel") {
//                            dismiss()
//                        }
//                    }
//                }
//        }
//    }
//}
