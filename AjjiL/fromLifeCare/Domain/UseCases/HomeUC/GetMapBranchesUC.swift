//
//  GetMapBranchesUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 29/04/2026.
//


import Foundation

final class GetMapBranchesUC {
    private let repo: HomeRepository
    
    init(repo: HomeRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [MapBranchEntity] {
        return try await repo.getMapBranches()
    }
}