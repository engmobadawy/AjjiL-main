import Foundation
// MARK: - Get Coupon Stores Use Case
class GetCouponStoresUseCase {
    private let repository: CouponsRepository
    
    init(repository: CouponsRepository) {
        self.repository = repository
    }
    
    func execute(couponId: Int) async throws -> [StoreModel] {
        return try await repository.getCouponStores(couponId: couponId)
    }
}
