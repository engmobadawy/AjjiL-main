import Foundation
import Combine

class StoreRepositoryImp: StoreRepository {
    func GetFeaturedProductsUCForStore(storeId: Int, branchId: Int, skip: Int, take: Int) async throws -> ProductListResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getFeaturedProducts(storeId: storeId, branchId: branchId, skip: skip, take: take),
            responseClass: ProductListResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
   
    func getHomeCategories(storeId: Int) async throws -> StoreCategoryResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getHomeCategories(storeId: storeId),
            responseClass: StoreCategoryResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getHomeOffers(storeId: Int, branchId: Int) async throws -> StoreHomeOffersResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getHomeOffers(storeId: storeId, branchId: branchId),
            responseClass: StoreHomeOffersResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getStoreSliders(storeId: Int) async throws -> StoreSliderResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getStoreSliders(storeId: storeId),
            responseClass: StoreSliderResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getProductDetails(branchProductId: Int) async throws -> ProductDetailResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getProductDetails(branchProductId: branchProductId),
            responseClass: ProductDetailResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getStoreSubcategories(storeId: Int) async throws -> StoreSubcategoryResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getStoreSubcategories(storeId: storeId),
            responseClass: StoreSubcategoryResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getStoreProducts(storeId: Int, branchId: Int, search: String) async throws -> ProductListResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getStoreProducts(storeId: storeId, branchId: branchId, search: search),
            responseClass: ProductListResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func getProductsByCategory(storeId: Int, branchId: Int, categoryId: Int) async throws -> ProductListResponse {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getProductsByCategory(storeId: storeId, branchId: branchId, categoryId: categoryId),
            responseClass: ProductListResponse.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
}
