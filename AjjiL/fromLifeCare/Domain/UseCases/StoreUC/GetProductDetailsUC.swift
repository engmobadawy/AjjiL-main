import Foundation

class GetProductDetailsUC {
    private let repo: StoreRepository
    
    init(repo: StoreRepository) {
        self.repo = repo
    }
    
    func execute(branchProductId: Int) async throws -> ProductDetailResponse {
        return try await repo.getProductDetails(branchProductId: branchProductId)
    }
}