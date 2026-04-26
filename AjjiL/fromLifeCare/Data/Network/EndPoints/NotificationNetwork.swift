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