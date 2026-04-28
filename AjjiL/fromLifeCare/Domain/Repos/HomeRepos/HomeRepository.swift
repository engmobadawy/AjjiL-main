import Foundation
import Combine

protocol HomeRepository {
    func getHomeBanners() async throws -> [HomeBannerDataEntity]
    func getHomeStores() async throws -> [HomeStoresDataEntity]
    func getFeaturedProducts() async throws -> [HomeFeaturedProductDataEntity]
    func getBranches(storeId: Int) async throws -> [BranchDataEntity]
    func getMapBranches() async throws -> [MapBranchEntity] // 👈 New Signature
}
