//
//  GetOrderHistoryUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/03/2026.
//

import Foundation

class GetOrderHistoryUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
   
    func execute(storeName: String? = nil, date: String? = nil) async throws -> [OrderHistoryEntity] {
        return try await repo.getOrderHistory(storeName: storeName, date: date)
    }
}
