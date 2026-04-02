//
//  ProfileNetwork.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//


import Foundation

enum ProfileNetwork {
    case getProfile
    case updateProfileInfo(name: String, email: String)
    case updateProfileImage(imageData: Data) 
}

extension ProfileNetwork: TargetType {
    var baseURL: String {
        return APIConfig.lifeCareBaseURL
    }

    var path: String {
        switch self {
        case .getProfile, .updateProfileInfo, .updateProfileImage:
       
            return "profile"
        }
    }

    var methods: HTTPMethod {
        switch self {
        case .getProfile:
            return .get
        case .updateProfileInfo, .updateProfileImage:
            return .post
        }
    }

    var task: TaskRequest {
        switch self {
        case .getProfile:
            return .requestPlain
            
        case .updateProfileInfo(let name, let email):
            let params: [String: Any] = [
                "name": name,
                "email": email
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
        case .updateProfileImage(let imageData):
            // Note: If your backend expects a base64 string for the image:
            let base64String = imageData.base64EncodedString()
            let params: [String: Any] = [
                "photo": "data:image/jpeg;base64,\(base64String)" // Adjust key/format to match your API
            ]
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
            
            /* * IMPORTANT: If your TaskRequest enum has a specific case for multipart 
             * form uploads (e.g., `.uploadMultipart`), you should use that instead 
             * of `.requestParameters` for the image. For example:
             *
             * return .uploadMultipart(data: imageData, name: "photo", fileName: "profile.jpg", mimeType: "image/jpeg")
             */
        }
    }

    var headers: [String: String]? {
        return NetWorkHelper.shared.Headers()
    }
}
