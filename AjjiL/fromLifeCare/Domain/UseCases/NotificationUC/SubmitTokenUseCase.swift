//
//  SubmitTokenUseCase.swift
//

import Foundation

// MARK: - Submit Token Use Case
class SubmitTokenUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func execute(token: String, deviceId: String) async throws -> SubmitTokenResponse {
        return try await repository.submitToken(token: token, deviceId: deviceId)
    }
}