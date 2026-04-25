import Foundation

protocol ContactRepository {
    func getContactTypes() async throws -> [ContactType]
    func sendContactUs(email: String, message: String, contactTypeId: Int) async throws -> String
}