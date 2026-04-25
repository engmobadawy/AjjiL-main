//
//  ContactNetwork.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 24/04/2026.
//


import Foundation

enum ContactNetwork {
    case getContactTypes
    case contactUs(email: String, message: String, contactTypeId: Int)
}

extension ContactNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getContactTypes:
            return "contact-type"
        case .contactUs:
            return "contact-us"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getContactTypes:
            return .get
        case .contactUs:
            return .post
        }
    }

    var task: TaskRequest {
        switch self {
        case .getContactTypes:
            return .requestPlain
            
        case .contactUs(let email, let message, let contactTypeId):
            let params: [String: Any] = [
                "email": email,
                "message": message,
                "contact_type_id": contactTypeId
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}






import Foundation

// MARK: - Contact Type Models
struct ContactTypeResponse: Decodable {
    let status: Bool?
    let message: String?
    let data: [ContactType]?
}

struct ContactType: Decodable, Identifiable {
    let id: Int
    let name: String
}

// MARK: - Contact Us Models
struct ContactUsResponse: Decodable {
    let status: Bool?
    let message: String?
}
