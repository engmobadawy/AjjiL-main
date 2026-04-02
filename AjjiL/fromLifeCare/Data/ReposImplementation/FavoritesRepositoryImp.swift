import Foundation
import Combine

class FavoritesRepositoryImp: FavoritesRepository {
   
    
    

    
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getFavoriteProducts() async throws -> [FavoriteProductDataEntity] {
        let publisher = networkService.fetchData(
            target: FavoritesNetwork.getFavoriteProducts,
            responseClass: FavoriteProductModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO.map()
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - NEW: Add Favorite Product Implementation
    func addFavoriteProduct(branchProductId: String) async throws -> ToggleFavoriteModel {
        let publisher = networkService.fetchData(
            target: FavoritesNetwork.addFavoriteProduct(branchProductId: branchProductId),
            responseClass: ToggleFavoriteModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    func removeFavoriteProduct(branchProductId: String) async throws -> ToggleFavoriteModel {
        let publisher = networkService.fetchData(
            target: FavoritesNetwork.removeFavoriteProduct(branchProductId: branchProductId),
            responseClass: ToggleFavoriteModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
}

// MARK: - Adapter for HomeProductCard
extension FavoriteProductDataEntity {
    var asHomeProduct: HomeFeaturedProductDataEntity {
        HomeFeaturedProductDataEntity(
            id: self.id,
            productId: self.productId,
            category: self.category,
            name: self.name,
            brand: self.brand,
            brandImage: self.brandImage,
            price: self.price,
            originalPrice: self.originalPrice,
            discount: self.discount,
            imageURL: self.imageURL,
            barcode: self.barcode, isFavorite: self.isFavorite
        )
    }
}
