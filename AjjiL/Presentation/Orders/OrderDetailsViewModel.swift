import SwiftUI

@MainActor
@Observable
final class OrderDetailsViewModel {
    private let getOrderDetailsUC: GetOrderDetailsUC
    
    private(set) var isLoading = false
    private(set) var order: OrderDetailEntity? = nil
    private(set) var errorMessage: String? = nil
    
    init(getOrderDetailsUC: GetOrderDetailsUC) {
        self.getOrderDetailsUC = getOrderDetailsUC
    }
    
    func fetchDetails(id: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            order = try await getOrderDetailsUC.execute(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}