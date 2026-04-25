//
//  ProfileRepository.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//


import Foundation
import Combine

// MARK: - Protocol Definition
protocol ProfileRepository {
    func getProfile() async throws -> ProfileEntity
    func updateProfileInfo(name: String, email: String) async throws -> ProfileModel
    func updateProfileImage(imageData: Data) async throws -> ProfileModel
    func changePassword(current: String, new: String, confirm: String) async throws -> String
    
    // MARK: - New Methods
    func changePhone(newPhone: String, password: String) async throws -> String
    func verifyChangePhone(newPhone: String, code: String) async throws -> String
    
    func getPromoCodes() async throws -> [PromoCodeDTO]
}

