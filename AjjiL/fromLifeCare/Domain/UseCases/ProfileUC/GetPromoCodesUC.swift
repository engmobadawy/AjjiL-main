//
//  GetPromoCodesUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 25/04/2026.
//


import Foundation

// MARK: - Get Promo Codes Use Case
class GetPromoCodesUC {
    private let repo: ProfileRepository
    
    init(repo: ProfileRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [PromoCodeDTO] {
        return try await repo.getPromoCodes()
    }
}