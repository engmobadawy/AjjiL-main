//
//  GetNotificationsUseCase.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 26/04/2026.
//


import Foundation

// MARK: - Get Notifications Use Case
class GetNotificationsUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [NotificationDTO] {
        return try await repository.getNotifications()
    }
}