//  LifeCare
//
//ForgetPasswordUseCase.swift

//                      
//

import Foundation
import Combine

final class ForgetPasswordUseCase {
  var authRepo: AuthRepository

  init(authRepo: AuthRepository) {
    self.authRepo = authRepo
  }

  func forgetAndNewPassword(with parameters: [String: Any]) async throws -> LoginModel{
   

    
          return try await authRepo.forgetAndNewPassword(with: parameters)
     
      
  }

}
