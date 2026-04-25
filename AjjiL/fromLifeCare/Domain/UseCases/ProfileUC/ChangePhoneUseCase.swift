import Foundation

// MARK: - Change Phone Use Case
class ChangePhoneUseCase {
    private let profileRepo: ProfileRepository
    
    init(profileRepo: ProfileRepository) {
        self.profileRepo = profileRepo
    }
    
    func execute(newPhone: String, password: String) async throws -> String {
        return try await profileRepo.changePhone(newPhone: newPhone, password: password)
    }
}

// MARK: - Verify Change Phone Use Case
class VerifyChangePhoneUseCase {
    private let profileRepo: ProfileRepository
    
    init(profileRepo: ProfileRepository) {
        self.profileRepo = profileRepo
    }
    
    func execute(newPhone: String, code: String) async throws -> String {
        return try await profileRepo.verifyChangePhone(newPhone: newPhone, code: code)
    }
}