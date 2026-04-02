import Foundation

class GetStoreSubcategoriesUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int) async throws -> StoreSubcategoryResponse {
        return try await repo.getStoreSubcategories(storeId: storeId)
    }
}