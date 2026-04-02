//
//  HomeRepositoryImp.swift
//  lifeCare
//
//  Created by mac on 29/10/2025.
//

import Foundation
import Combine

class HomeRepositoryImp: HomeRepository {
    
    
   
    
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
//    func getHomeData(id: Int?) -> AnyPublisher<HomeModel, any Error> {
//        networkService.fetchData(target: HomeNetwork.getHomeData(id: id), responseClass: HomeModel.self)
//    }
    

        func getHomeBanners() async throws -> [HomeBannerDataEntity] {
            let publisher = networkService.fetchData(
                target: HomeNetwork.getHomeBanners,
                responseClass: HomeBannerModel.self
            )
            
            // Await the first emitted value from the Combine publisher
            for try await bannerDTO in publisher.values {
                // Map the DTO to your entity model and return it
                return bannerDTO.map()
            }
            
            // Fallback in case the publisher completes without emitting a value
            throw URLError(.badServerResponse)
        }

    func getHomeStores() async throws -> [HomeStoresDataEntity] {
        let publisher = networkService.fetchData(
            target: HomeNetwork.getHomeStores,
            responseClass: HomeStoresModel.self
        )
        
        // Await the first emitted value from the Combine publisher
        for try await bannerDTO in publisher.values {
            // Map the DTO to your entity model and return it
            return bannerDTO.map()
        }
        
        // Fallback in case the publisher completes without emitting a value
        throw URLError(.badServerResponse)
    }
    

        func getFeaturedProducts() async throws -> [HomeFeaturedProductDataEntity] {
            let publisher = networkService.fetchData(
                target: HomeNetwork.getFeaturedProducts,
                responseClass: HomeFeaturedProductModel.self
            )
            
            for try await modelDTO in publisher.values {
                return modelDTO.map() // This correctly returns [HomeFeaturedProductDataEntity]
            }
            
            throw URLError(.badServerResponse)
        }
    
    func getBranches(storeId: Int) async throws -> [BranchDataEntity] {
        let publisher = networkService.fetchData(
            target: HomeNetwork.getBranches(storeId: storeId),
            responseClass: BranchModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO.map()
        }
        
        throw URLError(.badServerResponse)
    }
    
}
