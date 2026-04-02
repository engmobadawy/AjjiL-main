////
//  NetWorkHelper.swift

//

import UIKit
//import Alamofire
import Network

class NetWorkHelper{
    
    static var shared = NetWorkHelper()
    func Headers () -> [String:String] {
        let toLanguage = MOLHLanguage.currentAppleLanguage()
        let userDataUseCase = UserDataUseCase(userTokenRepository: DependencyContainer.UserTokenDependency.shared.userTokenRepository)
        let token = userDataUseCase.retrieveToken() ?? ""
        print("token is \(String(describing: token))")
        return [
          "token": token,
          "Authorization": "Bearer \(token)",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-Language":"\(toLanguage)",
          "Connection": "keep-alive",
          "X-device": "ios"

        ]
    }
    
    
    // Cancel Request
//    func CancelRequest() {
//        let sessionManager = Alamofire.Session.default.session
//        sessionManager.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
//            dataTasks.forEach { $0.cancel() }
//            uploadTasks.forEach { $0.cancel() }
//            downloadTasks.forEach { $0.cancel() }
//        }
//    }
}
