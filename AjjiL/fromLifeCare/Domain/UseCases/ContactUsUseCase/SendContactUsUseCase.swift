import Foundation

struct SendContactUsUseCase {
    private let repository: ContactRepository

    init(repository: ContactRepository) {
        self.repository = repository
    }

    func execute(email: String, message: String, contactTypeId: Int) async throws -> String {
        // You can add local validation logic here (e.g., regex to validate email format) 
        // before proceeding to call the repository.
        return try await repository.sendContactUs(
            email: email, 
            message: message, 
            contactTypeId: contactTypeId
        )
    }
}