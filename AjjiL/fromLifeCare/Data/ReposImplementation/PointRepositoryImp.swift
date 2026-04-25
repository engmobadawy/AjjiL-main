import Foundation
import Combine

class PointRepositoryImp: PointRepository {
    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getPoints() async throws -> PointsData {
        let publisher = networkService.fetchData(
            target: PointNetwork.getPoints,
            responseClass: PointsResponse.self
        )
        
        for try await response in publisher.values {
            if let data = response.data {
                return data
            }
        }
        
        throw URLError(.badServerResponse)
    }
    
    func redeemPoints(amount: Int) async throws -> RedeemPointsData {
        let publisher = networkService.fetchData(
            target: PointNetwork.redeemPoints(amount: amount),
            responseClass: RedeemPointsResponse.self
        )
        
        for try await response in publisher.values {
            if let data = response.data {
                return data
            }
        }
        
        throw URLError(.badServerResponse)
    }
    
    func calcPoints(amount: Int) async throws -> CalcPointsData {
        let publisher = networkService.fetchData(
            target: PointNetwork.calcPoints(amount: amount),
            responseClass: CalcPointsResponse.self
        )
        
        for try await response in publisher.values {
            if let data = response.data {
                return data
            }
        }
        
        throw URLError(.badServerResponse)
    }
}