
//
//  GetHomeBannersUC.swift
//  lifeCare
//
//  Created by mac on 29/10/2025.
//

import Foundation

final class GetHomeBannersUC {
    private let repo: HomeRepository
    
    init(repo: HomeRepository) {
        self.repo = repo
    }
    
    func execute() async throws -> [HomeBannerDataEntity] {
        return try await repo.getHomeBanners()
    }
}
