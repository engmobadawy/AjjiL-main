import Foundation

enum PointNetwork {
    case getPoints
    case redeemPoints(amount: Int)
    case calcPoints(amount: Int)
}

extension PointNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }
    
    var path: String {
        switch self {
        case .getPoints:
            return "points"
        case .redeemPoints:
            return "redeem-points"
        case .calcPoints:
            return "calc-points"
        }
    }
    
    var methods: HTTPMethod {
        // All three endpoints are explicitly GET requests
        switch self {
        case .getPoints, .redeemPoints, .calcPoints:
            return .get
        }
    }
    
    var task: TaskRequest {
        switch self {
        case .getPoints:
            return .requestPlain
            
        case .redeemPoints(let amount), .calcPoints(let amount):
            let params: [String: Any] = [
                "amount": amount
            ]
            // .inURLEncoding safely appends these as ?amount=X to the URL
            return .requestParameters(Parameters: params, encoding: .inURLEncoding)
        }
    }
    
    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}