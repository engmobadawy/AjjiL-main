//
//  OrdersViewModel.swift
//  AjjiLMB
//

import SwiftUI
import Combine

@MainActor
@Observable
final class OrdersViewModel {
    private let getOrderHistoryUC: GetOrderHistoryUC
    private let getCurrentOrdersUC: GetCurrentOrdersUC
    private let getQRCodeUC: GetQRCodeUC
    
    // MARK: - State
    var isLoadingHistory: Bool = false
    var historyOrders: [OrderHistoryEntity] = []
    
    var isLoadingCurrent: Bool = false
    var currentOrders: [OrderHistoryEntity] = []
    
    var isFetchingQR: Bool = false
    var errorMessage: String? = nil
    
    // MARK: - Init
    init(
        getOrderHistoryUC: GetOrderHistoryUC,
        getCurrentOrdersUC: GetCurrentOrdersUC,
        getQRCodeUC: GetQRCodeUC
    ) {
        self.getOrderHistoryUC = getOrderHistoryUC
        self.getCurrentOrdersUC = getCurrentOrdersUC
        self.getQRCodeUC = getQRCodeUC
    }
    
    // MARK: - Actions
    func fetchHistory(storeName: String? = nil, date: String? = nil) async {
        isLoadingHistory = true
        errorMessage = nil
        do {
            historyOrders = try await getOrderHistoryUC.execute(storeName: storeName, date: date)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingHistory = false
    }
    
    func fetchCurrentOrders(storeName: String? = nil, date: String? = nil) async {
        isLoadingCurrent = true
        errorMessage = nil
        do {
            currentOrders = try await getCurrentOrdersUC.execute(storeName: storeName, date: date)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoadingCurrent = false
    }
    
    func fetchQRCode(for orderId: Int) async -> QRCodeEntity? {
        isFetchingQR = true
        errorMessage = nil
        defer { isFetchingQR = false }
        
        do {
            return try await getQRCodeUC.execute(orderId: orderId)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Mappers
    func mapToConfig(_ entity: OrderHistoryEntity, isHistory: Bool) -> OrderCellConfig {
        let showBadge = shouldShowBadge(for: entity.statusId)
        
        let canScanCashier = !isHistory && !showBadge
        let canReturn = isHistory && entity.isReturnable && !showBadge
        
        return OrderCellConfig(
            id: entity.id,
            referenceNo: entity.referenceNo,
            dateString: entity.createdAt,
            storeName: entity.store,
            storeImageUrl: URL(string: entity.storeImage),
            totalAmount: "\(entity.grandTotal)",
            statusText: showBadge ? entity.statusName : nil,
            statusColor: color(for: entity.statusId),
            canReturn: canReturn,
            canScanCashier: canScanCashier
        )
    }
    
    // MARK: - Helpers
    private func shouldShowBadge(for statusId: Int) -> Bool {
        return statusId != 4
    }
    
    private func color(for statusId: Int) -> Color {
        switch statusId {
        case 6: return .orange
        case 7: return .red
        case 8: return Color(red: 0.16, green: 0.53, blue: 0.38)
        default: return Color(red: 0.16, green: 0.53, blue: 0.38)
        }
    }
}
