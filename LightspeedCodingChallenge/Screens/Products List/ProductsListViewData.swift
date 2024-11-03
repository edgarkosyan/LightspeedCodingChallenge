//
//  ProductsListViewData.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 03.11.24.
//

import Foundation

struct ProductsListViewData: Identifiable, Hashable {
    let id: Int
    let productTitle: String
    let imageURL: URL?
    let price: Double
    let quantity: Int
}

extension ProductsListViewData {
    static let previewMocks: [Self] = [
        previewMock1,
        previewMock2,
        previewMock3,
        previewMock4
    ]
    
    static let previewMock1: Self = .init(id: 1,
                                          productTitle: "Nivea",
                                          imageURL: nil,
                                          price: 2.99,
                                          quantity: 43)
    static let previewMock2: Self = .init(id: 2,
                                          productTitle: "Apple",
                                          imageURL: nil,
                                          price: 999.99,
                                          quantity: 100)
    static let previewMock3: Self = .init(id: 3,
                                          productTitle: "Hp",
                                          imageURL: nil,
                                          price: 499,
                                          quantity: 10)
    static let previewMock4: Self = .init(id: 4,
                                          productTitle: "Samsung",
                                          imageURL: nil,
                                          price: 499,
                                          quantity: 10)
}

protocol ProductsListTransformable {
    func transform(from model: ProductsContainerModel?) -> [ProductsListViewData]?
}

extension ProductsListTransformable {
    func transform(from model: ProductsContainerModel?) -> [ProductsListViewData]? {
        // Safely unwrap model
        guard let model else { return nil }
        
        // Use compactMap to transform products into ProductsListViewData
        return model.products?.compactMap { product in
            guard let id = product.id,
                  let productName = product.title,
                  let price = product.price,
                  let quantity = product.stock else { return nil }
            
            // Transformed image URL
            let imageUrl = transform(from: product.images?.first)
            
            return ProductsListViewData(id: id,
                                        productTitle: productName,
                                        imageURL: imageUrl,
                                        price: price,
                                        quantity: quantity)
        }
    }
    
    private func transform(from value: String?) -> URL? {
        guard let stringUrl = value else { return nil }
        
        return URL(string: stringUrl)
    }
}
