//
//  NotificationRepository.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 26/04/2026.
//


import Foundation
import Combine

// MARK: - Protocol Definition
protocol NotificationRepository {
    func getNotifications() async throws -> [NotificationDTO]
}