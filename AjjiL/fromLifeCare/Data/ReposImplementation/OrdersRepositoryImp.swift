//
//  OrdersRepositoryImp.swift
//  AjjiLMB
//

import Foundation
import Combine

class OrdersRepositoryImp: OrdersRepository {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getOrderHistory(storeName: String?, date: String?) async throws -> [OrderHistoryEntity] {
        let publisher = networkService.fetchData(target: OrdersNetwork.getOrderHistory(storeName: storeName, date: date), responseClass: OrderHistoryModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
    
    func getCurrentOrders(storeName: String?, date: String?) async throws -> [OrderHistoryEntity] {
        let publisher = networkService.fetchData(target: OrdersNetwork.getCurrentOrders(storeName: storeName, date: date), responseClass: OrderHistoryModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
    
    func getOrderDetails(id: Int) async throws -> OrderDetailEntity {
        let publisher = networkService.fetchData(target: OrdersNetwork.getOrderDetails(id: id), responseClass: OrderDetailModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
    
    func reviewOrder(id: Int, rate: Int, message: String) async throws -> SimpleActionEntity {
        let publisher = networkService.fetchData(target: OrdersNetwork.reviewOrder(id: id, rate: rate, message: message), responseClass: SimpleActionModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
    
    func getQRCode(orderId: Int) async throws -> QRCodeEntity {
        let publisher = networkService.fetchData(target: OrdersNetwork.getQRCode(orderId: orderId), responseClass: QRCodeDataModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
    
    func submitOrder(cartId: String, storeId: String, branchId: String, paymentMethod: String, couponCode: String?) async throws -> SubmitOrderEntity {
        let publisher = networkService.fetchData(target: OrdersNetwork.submitOrder(cartId: cartId, storeId: storeId, branchId: branchId, paymentMethod: paymentMethod, couponCode: couponCode), responseClass: SubmitOrderModel.self)
        for try await modelDTO in publisher.values { return modelDTO.map() }
        throw URLError(.badServerResponse)
    }
}
