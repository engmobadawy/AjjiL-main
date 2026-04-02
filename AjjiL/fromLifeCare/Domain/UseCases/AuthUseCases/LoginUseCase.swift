//  LifeCare
//
//LoginUseCase.swift

//Created by: M.Magdy on 5/5/25.
//

//import Foundation
//import Combine
//
//final class LoginUseCase {
//  var authRepo: AuthRepository
//
//  init(authRepo: AuthRepository) {
//    self.authRepo = authRepo
//  }
//
//  func login(with parameters: [String: Any]) -> AnyPublisher<LoginModel, Error> {
//    return authRepo.login(with: parameters)
//
//  }
//
//}

import Foundation

final class LoginUseCase {
    var authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func login(with parameters: [String: Any]) async throws -> LoginModel {
        return try await authRepo.login(with: parameters)
    }
}
