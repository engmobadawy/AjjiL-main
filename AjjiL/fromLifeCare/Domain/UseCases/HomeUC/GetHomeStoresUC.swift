//
//  GetHomeStoresUC.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 05/03/2026.
//

import Foundation

final class GetHomeStoresUC {
    private let repo: HomeRepository
    
    init(repo: HomeRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [HomeStoresDataEntity] {
        return try await repo.getHomeStores()
    }
}
