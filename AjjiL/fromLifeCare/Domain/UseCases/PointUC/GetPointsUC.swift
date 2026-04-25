//
//  GetPointsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


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