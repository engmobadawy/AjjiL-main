//
//  GetCurrentOrdersUC.swift
//  AjjiLMB
//

import Foundation

class GetCurrentOrdersUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
    func execute(storeName: String?, date: String?) async throws -> [OrderHistoryEntity] {
        return try await repo.getCurrentOrders(storeName: storeName, date: date)
    }
}