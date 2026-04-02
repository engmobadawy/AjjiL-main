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
}
