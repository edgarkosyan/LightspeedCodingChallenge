//
//  NetworkService.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 31.10.24.
//

import Foundation

public enum ModelLayersError: Error {
    case invalidURL
    case nextPageNotAvailable
    case decodableError
    case dataNil
    case taskCancelled
    case failedWith(message: String)
}

protocol NetworkServicing {
    func fetchProducts(page: Int) async -> Result<ProductsContainerModel, ModelLayersError>
}

class NetworkService: NetworkServicing {
    
    func fetchProducts(page: Int) async -> Result<ProductsContainerModel, ModelLayersError> {
        guard let url = URL(string: "https://dummyjson.com/products?limit=20&skip=\(page * 20)") else {
            return .failure(.invalidURL)
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            return .failure(.dataNil)
        }
        
        if let response = try? JSONDecoder().decode(ProductsContainerModel.self, from: data) {
            return .success(response)
        } else {
            print("Decoding failed")
            return .failure(.decodableError)
        }
    }
}

