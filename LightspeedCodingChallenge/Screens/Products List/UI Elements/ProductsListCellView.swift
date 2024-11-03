//
//  ProductsListCellView.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 03.11.24.
//

import SwiftUI

struct ProductsListCellView: View {
    let viewData: ProductsListViewData
    var body: some View {
        HStack(spacing: 20) {
            // Product Image
            CacheAsyncImage(url: viewData.imageURL) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .clipped()
                    .cornerRadius(8)
            } placeholder: {
                ProgressView()
                    .frame(width: 64, height: 64)
                    .tint(.gray)
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                // Product Title
                Text(viewData.productTitle)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2...2)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.7)
                
                // Product Price
                Text("price: \(String(format: "%.2f", viewData.price))")
                    .font(.callout)
                    .padding(.top, 0)
                
                // Product Quantity
                Text("quantity: \(viewData.quantity)")
                    .font(.callout)
                    .padding(.top, 0)
            }
            .frame(minWidth: .zero, maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
        }
        .padding(.horizontal, 10)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ProductsListCellView(viewData: ProductsListViewData.previewMock1)
}
