import Foundation

class GetStoreSlidersUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int) async throws -> StoreSliderResponse {
        return try await repo.getStoreSliders(storeId: storeId)
    }
}