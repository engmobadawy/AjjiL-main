import Foundation

class GetPointsUC {
    private let repo: PointRepository
    
    init(repo: PointRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> PointsData {
        return try await repo.getPoints()
    }
}