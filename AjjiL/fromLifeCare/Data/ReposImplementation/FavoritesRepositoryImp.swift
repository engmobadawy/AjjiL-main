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
// MARK: - Adapter for HomeProductCard
extension FavoriteProductDataEntity {
    var asHomeProduct: HomeFeaturedProductDataEntity {
        HomeFeaturedProductDataEntity(
            id: self.id,
            branchId: self.branchId,       // NEW
            productId: self.productId,
            name: self.name,
            category: self.category,
            storeId: self.storeId,         // NEW
            brand: self.brand,
            brandImage: self.brandImage,
            imageURL: self.imageURL,
            price: self.price,
            originalPrice: self.originalPrice,
            offerType: self.offerType,     // NEW (Optional)
            offerId: self.offerId,         // NEW (Optional)
            discount: self.discount,
            barcode: self.barcode,
            isFavorite: self.isFavorite
        )
    }
}
