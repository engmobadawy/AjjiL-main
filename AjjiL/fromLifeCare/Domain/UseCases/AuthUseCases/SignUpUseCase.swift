import Foundation

final class SignUpUseCase {
    var authRepo: AuthRepository

    init(authRepo: AuthRepository) {
        self.authRepo = authRepo
    }

    func signUp(with parameters: [String: Any]) async throws -> SignupModel {
        return try await authRepo.signUp(with: parameters)
    }
}
