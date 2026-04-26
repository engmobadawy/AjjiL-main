//
//  NotificationNetwork.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 26/04/2026.
//


import Foundation

enum NotificationNetwork {
    case getNotifications
}

extension NotificationNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getNotifications:
            return "notifications"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getNotifications:
            return .get
        }
    }

    var task: TaskRequest {
        switch self {
        case .getNotifications:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}





import Foundation

// MARK: - Notifications Response
struct NotificationsResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [NotificationDTO]?
    let count: Int?
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
