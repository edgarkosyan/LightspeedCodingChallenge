//
//  ProductsRepositoryTests.swift
//  LightspeedCodingChallengeTests
//
//  Created by edgar kosyan on 31.10.24.
//

import XCTest
@testable import LightspeedCodingChallenge

final class ProductsRepositoryTests: XCTestCase {
    var sut: NetworkServicing!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = NetworkService()
    }

    override func tearDownWithError() throws {
        sut = nil
        
        try super.tearDownWithError()
    }

    func testFetchProductsSuccess() async {
        let result = await sut.fetchProducts(page: 3)
      
        await MainActor.run {
            switch result {
            case .success(let productsContainer):
                XCTAssertNotNil(productsContainer)
                print("ProductsRepositoryTests: ProductsCount: \(productsContainer.products?.count)")
                XCTAssertFalse(productsContainer.products!.isEmpty)
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }
    }

}
