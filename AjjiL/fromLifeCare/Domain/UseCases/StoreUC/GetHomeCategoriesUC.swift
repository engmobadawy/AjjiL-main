import Foundation

class GetHomeCategoriesUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int) async throws -> StoreCategoryResponse {
        return try await repo.getHomeCategories(storeId: storeId)
    }
}