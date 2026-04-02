//  LifeCare
//
//UserTokenRepository.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation


protocol UserTokenRepository {
    func saveUserToken(token: String)
    func getUserToken() -> String?
    func clearUserToken()

    func saveUserData(user: UserData)
    func getUserData() -> UserData?
    func clearUserData()
}
