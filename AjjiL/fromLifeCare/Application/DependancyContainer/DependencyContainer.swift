//  LifeCare
//
//DependencyContainer.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation

class DependencyContainer {

    static let shared = DependencyContainer()

    // Network Service
    private(set) lazy var networkService: NetworkServiceProtocol = NetworkService()


    private init() {} 
}


extension DependencyContainer {
  class UserTokenDependency {

    static let shared = UserTokenDependency()

    // Repositories
    private(set) lazy var userTokenRepository = UserTokenRepositoryImpl()
    private(set) lazy var userDataUseCase = UserDataUseCase(userTokenRepository: userTokenRepository)

  }

  class ValidationDependency {

    static let shared = ValidationDependency()

    // Repositories
    private(set) lazy var inputValidator: InputValidator = ValidationHelper()
    private(set) lazy var userValidationUseCase = UserValidationUseCaseImpl(inputValidator: inputValidator)

  }
}




