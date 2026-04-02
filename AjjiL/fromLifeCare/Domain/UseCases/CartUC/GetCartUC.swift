//
//  GetCartUC.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 27/03/2026.
//


//
//  GetCartUC.swift
//  AjjiLMB
//

import Foundation

class GetCartUC {
    private let repo: CartRepository
    
    init(repo: CartRepository) {
        self.repo = repo
    }
    
    func execute(branchId: String) async throws -> CartEntity? {
        return try await repo.getCart(branchId: branchId)
    }
}