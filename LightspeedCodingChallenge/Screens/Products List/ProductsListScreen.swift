//
//  ProductsListScreen.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 31.10.24.
//

import SwiftUI

struct ProductsListScreen: View {
    @StateObject var viewModel: ProductsListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ProductsListViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                switch viewModel.viewState {
                case .idle:
                    EmptyView()
                case .loading:
                    loadingView
                case let .presenting(viewData):
                    presentingView(with: viewData)
                case let .error(message):
                    errorView(with: message)
                }
            }
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity, alignment: .top)
            .task { await viewModel.onAppear() }
            .refreshable(action: {
                withAnimation {
                    onRefresh()
                }
            })
            .navigationTitle("Products")
        }
    }
    
    private func presentingView(with viewData: [ProductsListViewData]) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            // Products List
            LazyVStack(spacing: 10) {
                ForEach(viewData) { viewDataItem in
                    // Product Cell
                    ProductsListCellView(viewData: viewDataItem)
                        .task {
                            await viewModel.onScrollChange(lastProductId: viewData.last?.id,
                                                           currentProductId: viewDataItem.id)
                        }
                }
                
                // Next Page Loading View
                if viewModel.isNextPageLoading {
                    nextPageLoadingView
                }
            }
            .padding(.bottom, 60)
        }
    }
    
    private var loadingView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(ProductsListViewData.previewMocks) { viewData in
                    ProductsListCellView(viewData: viewData)
                }
            }
            .redacted(reason: .placeholder)
        }
    }
    
    private func errorView(with message: String) -> some View {
        VStack(spacing: 40) {
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Button {
                Task {
                    await viewModel.onRefresh()
                }
            } label: {
                Text("Refresh")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.gray)
                    .cornerRadius(8)
            }
        }
        .frame(minWidth: .zero, maxWidth: .infinity, minHeight: .zero, maxHeight: .infinity)
    }
    
    private var nextPageLoadingView: some View {
        ProductsListCellView(viewData: ProductsListViewData.previewMock1)
            .redacted(reason: .placeholder)
    }
    
    private func onRefresh() {
        Task {
            await viewModel.onRefresh()
        }
    }
}

#Preview {
    ProductsListScreen()
}
