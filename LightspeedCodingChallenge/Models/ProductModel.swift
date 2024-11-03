//
//  ProductModel.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 31.10.24.
//

import Foundation

struct ProductModel: Codable {
    let id: Int?
    let title: String?
    let description: String?
    let category: String?
    let price: Double?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let tags: [String]?
    let brand: String?
    let sku: String?
    let weight: Int?
    let dimensions: DimensionsModel?
    let warrantyInformation: String?
    let shippingInformation: String?
    let availabilityStatus: String?
    let reviews: [ReviewModel]?
    let returnPolicy: String?
    let minimumOrderQuantity: Int?
    let meta: MetaModel?
    let images: [String]?
    let thumbnail: String?
}
