import Foundation

protocol CartRepository {
    func getCart(branchId: String) async throws -> CartEntity?
    func addProduct(branchId: String, productId: String, quantity: String, barcode: String?) async throws -> CartModel
    func removeProduct(itemId: String) async throws -> CartModel
    func addProductByBarcode(branchId: String, barcode: String, quantity: String) async throws -> CartModel
    func changeQuantity(itemId: String, quantity: String, branchId: String) async throws -> CartModel
}