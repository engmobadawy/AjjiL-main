//
//  UpdateProfileImageUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//

import Foundation
// MARK: - Update Profile Image Use Case
class UpdateProfileImageUC {
    private let repo: ProfileRepository
    
    init(repo: ProfileRepository) {
        self.repo = repo
    }
    
    func execute(imageData: Data) async throws -> ProfileModel {
        return try await repo.updateProfileImage(imageData: imageData)
    }
}
