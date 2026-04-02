//  LifeCare
//
// UserRepository.swift

// Created by: M.Magdy on 5/5/25.

//

import Foundation
import Combine
import UIKit

class AuthRepositoryImp: AuthRepository {
    func signUp(with parameters: [String : Any]) async throws -> SignupModel {
        let publisher = networkService.fetchData(
            target: AuthNetwork.signUp(params: parameters),
            responseClass: SignupModel.self
        )
        
        // Await the first emitted value from the Combine publisher
        for try await value in publisher.values {
            return value
        }
        
        // Fallback in case the publisher completes without emitting a value
        throw URLError(.badServerResponse)
    }
    
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

//    func signUp(parameters: [String : Any]) -> AnyPublisher<SignupModel, any Error> {
//        return networkService.fetchData(target: AuthNetwork.signUp(params: parameters), responseClass: SignupModel.self)
//    }
    
//    func login(with parameters: [String: Any]) -> AnyPublisher<LoginModel, Error> {
//        return networkService.fetchData(target: AuthNetwork.login(params: parameters), responseClass: LoginModel.self)
//    }
    
    func login(with parameters: [String: Any]) async throws -> LoginModel {
            let publisher = networkService.fetchData(
                target: AuthNetwork.login(params: parameters),
                responseClass: LoginModel.self
            )
            
            // Await the first emitted value from the Combine publisher
            for try await value in publisher.values {
                return value
            }
            
            // Fallback in case the publisher completes without emitting a value
            throw URLError(.badServerResponse)
        }
    
//    
    func sendCode(with parameters: [String: Any]) -> AnyPublisher<GeneralModel, Error> {
        return networkService.fetchData(target: AuthNetwork.sendCode(params: parameters), responseClass: GeneralModel.self)
    }
//    
//    
//    func verifyEmail(with parameters: [String : Any]) -> AnyPublisher<LoginModel, Error> {
//        return networkService.fetchData(target: AuthNetwork.verifyEmail(params: parameters), responseClass: LoginModel.self)
//    }
//    
    func verifyCode(with parameters: [String : Any]) -> AnyPublisher<GeneralModel, Error> {
        return networkService.fetchData(target: AuthNetwork.verifyCode(params: parameters), responseClass: GeneralModel.self)
    }
//    
    func forgetAndNewPassword(with parameters: [String: Any]) async throws -> LoginModel {

        
        let publisher = networkService.fetchData(
            target: AuthNetwork.forgetAndNewPassword(params: parameters),
            responseClass: LoginModel.self
        )
        
        // Await the first emitted value from the Combine publisher
        for try await value in publisher.values {
            return value
        }
        
        // Fallback in case the publisher completes without emitting a value
        throw URLError(.badServerResponse)
    }
    
   
    
    
}


