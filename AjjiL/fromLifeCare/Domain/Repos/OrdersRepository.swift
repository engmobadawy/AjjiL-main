import Foundation

protocol OrdersRepository {
    func getOrderHistory(storeName: String?, date: String?) async throws -> [OrderHistoryEntity]
    func getCurrentOrders(storeName: String?, date: String?) async throws -> [OrderHistoryEntity]
    func getOrderDetails(id: Int) async throws -> OrderDetailEntity
    func reviewOrder(id: Int, rate: Int, message: String) async throws -> SimpleActionEntity
    func getQRCode(orderId: Int) async throws -> QRCodeEntity
    func submitOrder(cartId: String, storeId: String, branchId: String, paymentMethod: String, couponCode: String?) async throws -> SubmitOrderEntity
}
