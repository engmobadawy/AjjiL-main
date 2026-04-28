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
    
    func getUnreadCount() async throws -> Int {
        let publisher = networkService.fetchData(
            target: NotificationNetwork.getUnreadCount,
            responseClass: UnreadCountResponse.self
        )
        
        for try await response in publisher.values {
            if let count = response.data {
                return count
            }
        }
        
        throw URLError(.badServerResponse)
    }
    
    // Add new implementation
    func submitToken(token: String, deviceId: String) async throws -> SubmitTokenResponse {
        let publisher = networkService.fetchData(
            target: NotificationNetwork.submitToken(token: token, deviceId: deviceId),
            responseClass: SubmitTokenResponse.self
        )
        
        for try await response in publisher.values {
            return response // Return the base response to handle status/message in the view model
        }
        
        throw URLError(.badServerResponse)
    }
}




// MARK: - Submit Token Response
struct SubmitTokenResponse: Decodable {
    let status: Bool?
    let message: String?
}

//// MARK: - Notifications Response
//struct NotificationsResponse: Decodable {
//    let status: Bool?
//    let message: String?
//    let data: [NotificationDTO]?
//    let count: Int?
//}
//
//// MARK: - Unread Count Response
//struct UnreadCountResponse: Decodable {
//    let status: Bool?
//    let message: String?
//    let data: Int?
//}
//
//// MARK: - Notification DTO
//struct NotificationDTO: Decodable, Identifiable {
//    let id: Int?
//    let isRead: Int?
//    let createdAt: String?
//    let title: String?
//    let body: String?
//    let type: Int?
//    let action: String?
//    let value: Int?
//    
//    enum CodingKeys: String, CodingKey {
//        case id, title, body, type, action, value
//        case isRead = "is_read"
//        case createdAt = "created_at"
//    }
//}
