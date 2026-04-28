import Foundation

// MARK: - Get Unread Notifications Count Use Case
class GetUnreadNotificationCountUseCase {
    private let repository: NotificationRepository
    
    init(repository: NotificationRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> Int {
        return try await repository.getUnreadCount()
    }
}