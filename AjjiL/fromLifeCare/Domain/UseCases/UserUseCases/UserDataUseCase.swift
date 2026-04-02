//  LifeCare
//
//userDataUseCase.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation

class UserDataUseCase {

    private let userTokenRepository: UserTokenRepository

    init(userTokenRepository: UserTokenRepository) {
        self.userTokenRepository = userTokenRepository
    }

    // Token Methods
    func saveToken(token: String) {
        userTokenRepository.saveUserToken(token: token)
    }

    func retrieveToken() -> String? {
        return userTokenRepository.getUserToken()
    }

    func clearUserToken() {
        userTokenRepository.clearUserToken()
    }

    // User Data Methods
    func saveUserData(user: UserData) {
        userTokenRepository.saveUserData(user: user)
    }

    func retrieveUserData() -> UserData? {
        return userTokenRepository.getUserData()
    }

    func clearUserData() {
        userTokenRepository.clearUserData()
    }
}
