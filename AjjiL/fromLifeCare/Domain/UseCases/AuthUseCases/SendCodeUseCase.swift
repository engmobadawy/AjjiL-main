//  LifeCare
//
//SendCodeUseCase.swift

//                      
//

import Foundation
import Combine

final class SendOTPUseCase {
  var authRepo: AuthRepository

  init(authRepo: AuthRepository) {
    self.authRepo = authRepo
  }

  func sendCode(with parameters: [String: Any]) -> AnyPublisher<GeneralModel, Error> {
    return authRepo.sendCode(with: parameters)

  }

}
