//  CouponsRepositoryImp.swift
import Foundation
import Combine

class CouponsRepositoryImp: CouponsRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Get Coupons
    func getCoupons(search: String?) async throws -> [CouponModel] {
        let publisher = networkService.fetchData(
            target: CouponsNetwork.getCoupons(search: search),
            responseClass: BaseDataResponse<[CouponModel]>.self
        )
        
        for try await response in publisher.values {
            return response.data ?? []
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Get Branches
    func getCouponBranches(couponId: Int) async throws -> [BranchModel] {
        let publisher = networkService.fetchData(
            target: CouponsNetwork.getCouponBranches(couponId: couponId),
            responseClass: BaseDataResponse<[BranchModel]>.self
        )
        
        for try await response in publisher.values {
            return response.data ?? []
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Get Stores
    func getCouponStores(couponId: Int) async throws -> [StoreModel] {
        let publisher = networkService.fetchData(
            target: CouponsNetwork.getCouponStores(couponId: couponId),
            responseClass: BaseDataResponse<[StoreModel]>.self
        )
        
        for try await response in publisher.values {
            return response.data ?? []
        }
        
        throw URLError(.badServerResponse)
    }
}