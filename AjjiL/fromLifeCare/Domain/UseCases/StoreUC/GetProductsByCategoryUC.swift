import Foundation

class GetProductsByCategoryUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    // CHANGED: Return type is now CategoryProductsResponse
    func execute(storeId: Int, branchId: Int, categoryId: Int) async throws -> CategoryProductsResponse {
        return try await repo.getProductsByCategory(storeId: storeId, branchId: branchId, categoryId: categoryId)
    }
}
