//
//  UpdateProfileInfoUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//

import Foundation
// MARK: - Update Profile Info Use Case
class UpdateProfileInfoUC {
    private let repo: ProfileRepository
    
    init(repo: ProfileRepository) {
        self.repo = repo
    }
    
    func execute(name: String, email: String) async throws -> ProfileModel {
        return try await repo.updateProfileInfo(name: name, email: email)
    }
}

