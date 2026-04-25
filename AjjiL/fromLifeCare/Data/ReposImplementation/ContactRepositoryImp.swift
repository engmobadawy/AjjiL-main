import Foundation
import Combine

class ContactRepositoryImp: ContactRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Get Contact Types
    func getContactTypes() async throws -> [ContactType] {
        let publisher = networkService.fetchData(
            target: ContactNetwork.getContactTypes,
            responseClass: ContactTypeResponse.self
        )
        
        for try await response in publisher.values {
            return response.data ?? []
        }
        
        throw URLError(.badServerResponse)
    }
    
    // MARK: - Send Contact Us
    func sendContactUs(email: String, message: String, contactTypeId: Int) async throws -> String {
        let publisher = networkService.fetchData(
            target: ContactNetwork.contactUs(email: email, message: message, contactTypeId: contactTypeId),
            responseClass: ContactUsResponse.self
        )
        
        for try await response in publisher.values {
            return response.message ?? "Request Sent Successfully"
        }
        
        throw URLError(.badServerResponse)
    }
}