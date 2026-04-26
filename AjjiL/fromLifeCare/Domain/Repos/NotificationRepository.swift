import Foundation
import Combine

// MARK: - Protocol Definition
protocol NotificationRepository {
    func getNotifications() async throws -> [NotificationDTO]
}