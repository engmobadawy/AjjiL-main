//
//  GetQRCodeUC.swift
//  AjjiLMB
//

import Foundation

class GetQRCodeUC {
    private let repo: OrdersRepository
    
    init(repo: OrdersRepository) {
        self.repo = repo
    }
    
    func execute(orderId: Int) async throws -> QRCodeEntity {
        return try await repo.getQRCode(orderId: orderId)
    }
}