//
//  StoreRepository 2.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 02/04/2026.
//


import Foundation

protocol StoreRepository {
    func GetFeaturedProductsUCForStore(storeId: Int, branchId: Int, skip: Int, take: Int) async throws -> ProductListResponse
    func getHomeCategories(storeId: Int) async throws -> StoreCategoryResponse
    func getHomeOffers(storeId: Int, branchId: Int) async throws -> StoreHomeOffersResponse
    func getStoreSliders(storeId: Int) async throws -> StoreSliderResponse
    func getProductDetails(branchProductId: Int) async throws -> ProductDetailResponse
    func getStoreSubcategories(storeId: Int) async throws -> StoreSubcategoryResponse
    func getStoreProducts(storeId: Int, branchId: Int, search: String) async throws -> CategoryProductsResponse
    func getProductsByCategory(storeId: Int, branchId: Int, categoryId: Int) async throws -> CategoryProductsResponse
}
