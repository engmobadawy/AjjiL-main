//  LifeCare
//
//UserTokenRepositoryImpl.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation

class UserTokenRepositoryImpl: UserTokenRepository {

//    private let userDefaults = UserDefaults.standard
    private let tokenKey = Constants.shared.token
    private let userDataKey = Constants.shared.userDataKey

    func saveUserToken(token: String) {
      GenericUserDefault.shared.setValue(token, tokenKey)
//        userDefaults.set(token, forKey: tokenKey)
    }

    func getUserToken() -> String? {
      GenericUserDefault.shared.getValue(tokenKey) as? String
//        return userDefaults.string(forKey: tokenKey)
    }

    func clearUserToken() {
      GenericUserDefault.shared.removeValue(tokenKey)
//        userDefaults.removeObject(forKey: tokenKey)
    }

    func saveUserData(user: UserData) {
      GenericUserDefault.shared.setObject(userDataKey, user)
//        if let encodedUser = try? JSONEncoder().encode(user) {
//            userDefaults.set(encodedUser, forKey: userDataKey)
//        }
    }

    func getUserData() -> UserData? {
      return GenericUserDefault.shared.getObject(userDataKey, result: UserData.self)
//        guard let data = userDefaults.data(forKey: userDataKey) else { return nil }
//        return try? JSONDecoder().decode(UserData.self, from: data)
    }

    func clearUserData() {
      GenericUserDefault.shared.removeValue(userDataKey)
//        userDefaults.removeObject(forKey: userDataKey)
    }
}
