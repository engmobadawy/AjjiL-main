//
//  GetCouponBranchesUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import Foundation

// ... (GetCouponsUseCase remains the same) ...

// MARK: - Get Coupon Branches Use Case (Updated)
class GetCouponBranchesUseCase {
    private let repository: CouponsRepository
    
    init(repository: CouponsRepository) {
        self.repository = repository
    }
    
    func execute(couponId: Int) async throws -> [BranchData] {
        return try await repository.getCouponBranches(couponId: couponId)
    }
}