import Foundation
import Combine

// MARK: - Protocol Definition
protocol NotificationRepository {
    func getNotifications() async throws -> [NotificationDTO]
    func getUnreadCount() async throws -> Int
    func submitToken(token: String, deviceId: String) async throws -> SubmitTokenResponse // Add new method
}
