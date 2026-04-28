import Foundation

enum NotificationNetwork {
    case getNotifications
    case getUnreadCount // Add new case
    case submitToken(token: String, deviceId: String)
}

extension NotificationNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getNotifications:
            return "notifications"
        case .getUnreadCount:
            return "notifications/unread-count" // Add new path
        case .submitToken:
                    return "notifications/submit-token"
        }
    }

    var methods: HTTPMethod {
            switch self {
            case .getNotifications, .getUnreadCount:
                return .get
            case .submitToken:
                return .post // Use POST
            }
        }

    var task: TaskRequest {
            switch self {
            case .getNotifications, .getUnreadCount:
                return .requestPlain
                
            case .submitToken(let token, let deviceId):
                let params: [String: Any] = [
                    "token": token,
                    "device_id": deviceId
                ]
                // Notice the capital 'P' in Parameters:
                return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            }
        }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}

// MARK: - Notifications Response
struct NotificationsResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [NotificationDTO]?
    let count: Int?
}

// MARK: - Unread Count Response
struct UnreadCountResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: Int? // Assuming the API returns the integer directly in `data`
}

// MARK: - Notification DTO
struct NotificationDTO: Decodable, Identifiable {
    let id: Int?
    let isRead: Int?
    let createdAt: String?
    let title: String?
    let body: String?
    let type: Int?
    let action: String?
    let value: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, title, body, type, action, value
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
