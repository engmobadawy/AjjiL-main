import Foundation

struct GetContactTypesUseCase {
    private let repository: ContactRepository

    init(repository: ContactRepository) {
        self.repository = repository
    }

    func execute() async throws -> [ContactType] {
        return try await repository.getContactTypes()
    }
}