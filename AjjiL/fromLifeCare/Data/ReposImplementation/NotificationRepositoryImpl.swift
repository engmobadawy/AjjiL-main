//
//  NotificationRepository.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 26/04/2026.
//


import Foundation
import Combine



// MARK: - Implementation
class NotificationRepositoryImpl: NotificationRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getNotifications() async throws -> [NotificationDTO] {
        let publisher = networkService.fetchData(
            target: NotificationNetwork.getNotifications,
            responseClass: NotificationsResponse.self
        )
        
        for try await response in publisher.values {
            if let data = response.data {
                return data
            }
        }
        
        throw URLError(.badServerResponse)
    }
}
