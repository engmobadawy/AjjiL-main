//
//  ChangePasswordUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/04/2026.
//


// ChangePasswordUseCase.swift
import Foundation

protocol ChangePasswordUseCase {
    func execute(current: String, new: String, confirm: String) async throws -> String
}

class ChangePasswordUseCaseImpl: ChangePasswordUseCase {
    private let profileRepo: ProfileRepository
    
    init(profileRepo: ProfileRepository) {
        self.profileRepo = profileRepo
    }
    
    func execute(current: String, new: String, confirm: String) async throws -> String {
        return try await profileRepo.changePassword(current: current, new: new, confirm: confirm)
    }
}