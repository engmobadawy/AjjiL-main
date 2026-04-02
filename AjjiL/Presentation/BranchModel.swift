// MARK: - Branch API Models

struct BranchModel: Codable {
    let status: Bool?
    let message: String?
    let data: [BranchData]?
}

struct BranchData: Codable {
    let id: Int?
    let name: String?
    let lat: String?
    let lng: String?
    let address: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, lat, lng, address
        case createdAt = "created_at"
    }
}

// MARK: - Domain Entity
struct BranchDataEntity: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let lat: String
    let lng: String
    let address: String
}

// MARK: - Mappers
extension BranchModel {
    func map() -> [BranchDataEntity] {
        return data?.compactMap { $0.map() } ?? []
    }
}

extension BranchData {
    func map() -> BranchDataEntity {
        BranchDataEntity(
            id: self.id ?? 0,
            name: self.name ?? "",
            lat: self.lat ?? "",
            lng: self.lng ?? "",
            address: self.address ?? ""
        )
    }
}