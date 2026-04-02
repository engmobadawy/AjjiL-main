//
//  GetOrderDetailsUC.swift
//  AjjiLMB
//

import Foundation

class GetOrderDetailsUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
    func execute(id: Int) async throws -> OrderDetailEntity {
        return try await repo.getOrderDetails(id: id)
    }
}