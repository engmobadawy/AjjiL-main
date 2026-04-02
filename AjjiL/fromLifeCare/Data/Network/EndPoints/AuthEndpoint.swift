//  LifeCare
//
//ApiEndpoint.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation


enum AuthNetwork {
    case signUp(params:[String:Any])
    case login(params:[String:Any])
    case forgetAndNewPassword(params:[String:Any])
    case sendCode(params:[String:Any])
    case verifyEmail(params:[String:Any])
    case verifyCode(params:[String:Any])
}


extension AuthNetwork : TargetType {
    var baseURL: String {
        let source = APIConfig.lifeCareBaseURL
        return source
    }

    var path: String {
        switch self {
        case .signUp: return "register"
        case .login: return "login"
        case .forgetAndNewPassword: return "new-password"
        case .sendCode: return "send-code"
        case .verifyEmail: return "verify"
        case .verifyCode: return "verify-code"
        
        }
    }

    var methods: HTTPMethod {
        switch self {
        default: return .post

        }
    }

    var task: TaskRequest {
        switch self{
        case  let .login(params), let .signUp(params), let .forgetAndNewPassword(params), let .verifyEmail(params), let .verifyCode(params), let .sendCode(params):
            return .requestParameters(Parameters: params, encoding: .inBodyEncoding)
        
        }
    }

    var headers: [String : String]? {
        switch self {
        default:
            return NetWorkHelper.shared.Headers()
        }
    }

}
