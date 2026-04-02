protocol FavoritesRepository {
    func getFavoriteProducts() async throws -> [FavoriteProductDataEntity]
    func addFavoriteProduct(branchProductId: String) async throws -> ToggleFavoriteModel
    func removeFavoriteProduct(branchProductId: String) async throws -> ToggleFavoriteModel 
}
