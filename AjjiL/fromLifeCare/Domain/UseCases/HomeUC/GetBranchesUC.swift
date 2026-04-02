import Foundation

final class GetBranchesUC {
    private let repo: HomeRepository
    
    init(repo: HomeRepository) {
        self.repo = repo
    }
    
    func execute(storeId: Int) async throws -> [BranchDataEntity] {
        return try await repo.getBranches(storeId: storeId)
    }
}