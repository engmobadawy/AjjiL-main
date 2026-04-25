import Foundation

class RedeemPointsUC {
    private let repo: PointRepository
    
    init(repo: PointRepository) {
        self.repo = repo
    }
    
    func execute(amount: Int) async throws -> RedeemPointsData {
        return try await repo.redeemPoints(amount: amount)
    }
}