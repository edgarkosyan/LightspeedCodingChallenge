//
//  ProductsContainerModel.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 31.10.24.
//

import Foundation

struct ProductsContainerModel: Codable {
    let products: [ProductModel]?
    let total: Int?
    let skip: Int?
    let limit: Int?
}
