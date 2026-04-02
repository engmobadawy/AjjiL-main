import Foundation
// MARK: - Models
struct PromoImage: Identifiable {
    let id = UUID()
    let imageName: String
}

struct CategoryImage: Identifiable {
    let id = UUID()
    let imageName: String
}

// Mock Data (Replace with your actual image assets)
let mockPromoImages = [
    PromoImage(imageName: "discount_img_1"),
    PromoImage(imageName: "discount_img_2"),
    PromoImage(imageName: "discount_img_3")
]

let mockCategoryImages = [
    CategoryImage(imageName: "cat_grocery_img"),
    CategoryImage(imageName: "cat_veg_img"),
    CategoryImage(imageName: "cat_personal_img"),
    CategoryImage(imageName: "cat_detergent_img"),
    CategoryImage(imageName: "cat_baby_img"),
    CategoryImage(imageName: "cat_stationery_img")
]
