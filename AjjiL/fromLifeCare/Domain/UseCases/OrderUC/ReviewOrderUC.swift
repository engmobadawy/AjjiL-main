//
//  ReviewOrderUC.swift
//  AjjiLMB
//

import Foundation

class ReviewOrderUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
    func execute(id: Int, rate: Int, message: String) async throws -> SimpleActionEntity {
        return try await repo.reviewOrder(id: id, rate: rate, message: message)
    }
}