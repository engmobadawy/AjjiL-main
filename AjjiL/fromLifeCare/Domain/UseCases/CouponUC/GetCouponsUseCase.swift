//
//  GetCouponsUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import Foundation

// MARK: - Get Coupons Use Case
class GetCouponsUseCase {
    private let repository: CouponsRepository
    
    init(repository: CouponsRepository) {
        self.repository = repository
    }
    
    func execute(search: String? = nil) async throws -> [CouponModel] {
        return try await repository.getCoupons(search: search)
    }
}
