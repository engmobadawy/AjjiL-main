import Foundation

class GetStoreProductsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int, branchId: Int, search: String) async throws -> ProductListResponse {
        return try await repo.getStoreProducts(storeId: storeId, branchId: branchId, search: search)
    }
}