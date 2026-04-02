//  LifeCare
//
//AuthRepository.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation
import Combine
import UIKit

protocol AuthRepository {
//    func signUp(parameters: [String: Any]) -> AnyPublisher<SignupModel, Error>
    func signUp(with parameters: [String: Any]) async throws -> SignupModel
    func login(with parameters: [String: Any]) async throws -> LoginModel
    func sendCode(with parameters: [String: Any]) -> AnyPublisher<GeneralModel, Error>
//    func verifyEmail(with parameters: [String: Any]) -> AnyPublisher<LoginModel, Error>
//    func verifyCode(with parameters: [String: Any]) -> AnyPublisher<GeneralModel, Error>
    func forgetAndNewPassword(with parameters: [String: Any]) async throws ->LoginModel
}

