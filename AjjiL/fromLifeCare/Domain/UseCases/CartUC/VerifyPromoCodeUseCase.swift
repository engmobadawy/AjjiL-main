import Foundation
import Combine

class VerifyPromoCodeUseCase {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func execute(cartId: String, couponCode: String) async throws -> VerifyPromoCodeResponse {
        let publisher = networkService.fetchData(
            target: CartNetwork.verifyPromoCode(cartId: cartId, couponCode: couponCode),
            responseClass: VerifyPromoCodeResponse.self
        )
        
        // Await the first value from the Combine publisher
        for try await responseModel in publisher.values {
            return responseModel
        }
        
        throw URLError(.badServerResponse)
    }
}