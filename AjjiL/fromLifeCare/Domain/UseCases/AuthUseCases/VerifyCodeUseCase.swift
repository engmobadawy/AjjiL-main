////  LifeCare
////
////VerifyCodeUseCase.swift
//
////                      
////
//
//import Foundation
//import Combine
//
//final class VerifyCodeUseCase {
//  var authRepo: AuthRepository
//
//  init(authRepo: AuthRepository) {
//    self.authRepo = authRepo
//  }
//
//  func verifyCode(with parameters: [String: Any]) -> AnyPublisher<GeneralModel, Error> {
//    return authRepo.verifyCode(with: parameters)
//
//  }
//
//    func verifyEmail(with parameters: [String: Any]) -> AnyPublisher<LoginModel, Error> {
//    return authRepo.verifyEmail(with: parameters)
//
//  }
//
//}
