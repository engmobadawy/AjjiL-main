//  CouponsRepository.swift
import Foundation

protocol CouponsRepository {
    func getCoupons(search: String?) async throws -> [CouponModel]
    func getCouponBranches(couponId: Int) async throws -> [BranchModel]
    func getCouponStores(couponId: Int) async throws -> [StoreModel]
}