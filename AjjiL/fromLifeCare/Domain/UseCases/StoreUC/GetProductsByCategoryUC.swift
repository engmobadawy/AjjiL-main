import Foundation

class GetProductsByCategoryUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int, branchId: Int, categoryId: Int) async throws -> ProductListResponse {
        return try await repo.getProductsByCategory(storeId: storeId, branchId: branchId, categoryId: categoryId)
    }
}