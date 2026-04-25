//
//  CalcPointsUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


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