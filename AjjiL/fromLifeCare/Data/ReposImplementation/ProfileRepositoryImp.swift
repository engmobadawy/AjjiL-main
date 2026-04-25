//
//  ProfileRepository.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//


import Foundation
import Combine


// MARK: - Implementation
class ProfileRepositoryImp: ProfileRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Get Profile
   func getProfile() async throws -> ProfileEntity {
            // 1. Decode directly into ProfileData instead of ProfileModel
            let publisher = networkService.fetchData(
                target: ProfileNetwork.getProfile,
                responseClass: ProfileData.self
            )
            
            for try await modelDTO in publisher.values {
                // 2. modelDTO is now ProfileData, so it always maps to a non-optional ProfileEntity
                let entity = modelDTO.map()
                return entity
            }
            
            throw URLError(.badServerResponse)
        }
    
    // MARK: - Update Profile Info
    func updateProfileInfo(name: String, email: String) async throws -> ProfileModel {
        let publisher = networkService.fetchData(
            target: ProfileNetwork.updateProfileInfo(name: name, email: email),
            responseClass: ProfileModel.self
        )
        
        for try await modelDTO in publisher.values {
            // Returning the raw DTO, assuming the API returns the updated profile.
            // You can also map this to ProfileEntity if you prefer.
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Update Profile Image
    func updateProfileImage(imageData: Data) async throws -> ProfileModel {
        let publisher = networkService.fetchData(
            target: ProfileNetwork.updateProfileImage(imageData: imageData),
            responseClass: ProfileModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func changePassword(current: String, new: String, confirm: String) async throws -> String {
        let publisher = networkService.fetchData(
            target: ProfileNetwork.changePassword(current: current, new: new, confirm: confirm),
            responseClass: ChangePasswordResponse.self
        )
        
        for try await response in publisher.values {
            return response.message ?? "Password updated successfully"
        }
        
        throw URLError(.badServerResponse)
    }
    
    
    func changePhone(newPhone: String, password: String) async throws -> String {
            let publisher = networkService.fetchData(
                target: ProfileNetwork.changePhone(newPhone: newPhone, password: password),
                responseClass: ChangePhoneResponse.self
            )
            
            for try await response in publisher.values {
                return response.message ?? "Code sent successfully"
            }
            
            throw URLError(.badServerResponse)
        }
        
        func verifyChangePhone(newPhone: String, code: String) async throws -> String {
            let publisher = networkService.fetchData(
                target: ProfileNetwork.verifyChangePhone(newPhone: newPhone, code: code),
                responseClass: ChangePhoneResponse.self
            )
            
            for try await response in publisher.values {
                return response.message ?? "Phone verified successfully"
            }
            
            throw URLError(.badServerResponse)
        }
    
    func getPromoCodes() async throws -> [PromoCodeDTO] {
            let publisher = networkService.fetchData(
                target: ProfileNetwork.getPromoCodes,
                responseClass: PromoCodesResponse.self
            )
            
            for try await response in publisher.values {
                // Unwrapping the data array or returning an empty array if nil
                return response.data ?? []
            }
            
            throw URLError(.badServerResponse)
        }
    
}
