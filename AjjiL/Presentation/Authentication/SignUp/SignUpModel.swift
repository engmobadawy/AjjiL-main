import Foundation

struct SignupModel: Codable {
    let name: String
    let userId: Int
    let success: Bool
    
    enum CodingKeys: String, CodingKey {
        case name
        case userId = "user_id"
        case success
    }
}