import Foundation
import Combine

class StoreRepositoryImp: StoreRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getFeaturedProducts(storeId: Int, branchId: Int, skip: Int, take: Int) async throws -> [StoreFeaturedProductDataEntity] {
        let publisher = networkService.fetchData(
            target: StoreNetwork.getFeaturedProducts(storeId: storeId, branchId: branchId, skip: skip, take: take),
            responseClass: StoreFeaturedProductModel.self
        )
        
        // Await the first emitted value from the Combine publisher
        for try await modelDTO in publisher.values {
            return modelDTO.map()
        }
        
        // Fallback in case the publisher completes without emitting a value
        throw URLError(.badServerResponse)
    }
}
