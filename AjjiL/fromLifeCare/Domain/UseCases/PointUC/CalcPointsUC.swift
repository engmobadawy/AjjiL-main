import Foundation

class CalcPointsUC {
    private let repo: PointRepository
    
    init(repo: PointRepository) {
        self.repo = repo
    }
    
    func execute(amount: Int) async throws -> CalcPointsData {
        return try await repo.calcPoints(amount: amount)
    }
}