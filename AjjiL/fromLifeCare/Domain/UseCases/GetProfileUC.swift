//
//  GetProfileUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//


import Foundation

// MARK: - Get Profile Use Case
class GetProfileUC {
    private let repo: ProfileRepository
    
    init(repo: ProfileRepository) {
        self.repo = repo
    }
    
    
    func execute() async throws -> ProfileEntity {
        return try await repo.getProfile()
    }
}
