//
//  CouponsRepository.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//



import Foundation

protocol CouponsRepository {
    func getCoupons(search: String?) async throws -> [CouponModel]
    func getCouponBranches(couponId: Int) async throws -> [BranchData] // Updated to BranchData
    func getCouponStores(couponId: Int) async throws -> [StoreModel]
}
