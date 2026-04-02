//
//  HomeRepository.swift
//  lifeCare
//
//  Created by mac on 29/10/2025.
//

import Foundation
import Combine

protocol HomeRepository {
//    func getHomeData(id: Int?) -> AnyPublisher<HomeModel, Error>
   
    func getHomeBanners() async throws -> [HomeBannerDataEntity]
    func getHomeStores() async throws -> [HomeStoresDataEntity]
    func getFeaturedProducts() async throws -> [HomeFeaturedProductDataEntity]
    func getBranches(storeId: Int) async throws -> [BranchDataEntity]
    
    
}
