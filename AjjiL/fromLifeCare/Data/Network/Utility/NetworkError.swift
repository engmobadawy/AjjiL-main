//  LifeCare
//
//NetworkError6.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation


enum NetworkError: LocalizedError {
    case invalidURL
    case unauthorized
    case rateLimited
    case requestFailed(statusCode: Int)
    case requestFailedWithMessage(statusCode: Int, message: String)
    case decodingFailed
    case unknown(Error)
    

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .unauthorized:
            return "Wrong_login_credentials.".localized()//You are not authorized to access this resource."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .requestFailed(let statusCode):
            return "Request failed with status code \(statusCode)."
        case .requestFailedWithMessage(_, let message):
            return "\(message)"
        case .decodingFailed:
            return "Failed to decode the response."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

struct ErrorResponse: Codable {
    var status: Bool?
    var message: String?
}

struct errorData: Codable {
    var errorText: String?
}
