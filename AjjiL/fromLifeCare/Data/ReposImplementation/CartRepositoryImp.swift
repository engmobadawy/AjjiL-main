import Foundation
import Combine

class CartRepositoryImp: CartRepository {
    func removeProduct(itemId: String) async throws -> SimpleActionModel {
        let publisher = networkService.fetchData(
                    target: CartNetwork.removeProduct(itemId: itemId),
                    responseClass: SimpleActionModel.self   // Changed from CartModel
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
    
    // MARK: - Get Cart
    func getCart(branchId: String) async throws -> CartEntity? {
        let publisher = networkService.fetchData(
            target: CartNetwork.getCart(branchId: branchId),
            responseClass: CartModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO.map()
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Add Product
    func addProduct(branchId: String, productId: String, quantity: String, barcode: String?) async throws -> CartModel {
        let publisher = networkService.fetchData(
            target: CartNetwork.addProduct(branchId: branchId, productId: productId, quantity: quantity, barcode: barcode),
            responseClass: CartModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
//    // MARK: - Remove Product
//    func removeProduct(itemId: String) async throws -> CartModel {
//        let publisher = networkService.fetchData(
//            target: CartNetwork.removeProduct(itemId: itemId),
//            responseClass: CartModel.self
//        )
//        
//        for try await modelDTO in publisher.values {
//            return modelDTO
//        }
//        
//        throw URLError(.badServerResponse)
//    }
    
    // MARK: - Add Product by Barcode
    func addProductByBarcode(branchId: String, barcode: String, quantity: String) async throws -> CartModel {
        let publisher = networkService.fetchData(
            target: CartNetwork.addProductByBarcode(branchId: branchId, barcode: barcode, quantity: quantity),
            responseClass: CartModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Change Quantity
    func changeQuantity(itemId: String, quantity: String, branchId: String) async throws -> CartModel {
        let publisher = networkService.fetchData(
            target: CartNetwork.changeQuantity(itemId: itemId, quantity: quantity, branchId: branchId),
            responseClass: CartModel.self
        )
        
        for try await modelDTO in publisher.values {
            return modelDTO
        }
        
        throw URLError(.badServerResponse)
    }
}
