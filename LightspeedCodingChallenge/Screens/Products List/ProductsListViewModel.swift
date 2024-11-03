//
//  ProductsListViewModel.swift
//  LightspeedCodingChallenge
//
//  Created by edgar kosyan on 31.10.24.
//

import Foundation

final class ProductsListViewModel: ObservableObject {
    
    // Define the different states the view can be in
    enum ViewState: Equatable {
        case idle // Initial state, no data loaded
        case loading // Data is currently being loaded
        case presenting(viewData: [ProductsListViewData]) // Data loaded and displayed
        case error(message: String)  // An error occurred, display the error message
    }
    
    // MARK: - Published Properties
    
    @Published var viewState: ViewState = .idle
    @Published var isNextPageLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let networkService: NetworkServicing
    private var page: Int = 0
    private var canFetchNextPage: Bool = false
    private var isPaginationCompleted: Bool = false
    
    // Track the current task to support cancellation
    private var currentTask: Task<Void, Never>? = nil
    
    // MARK: - Initializer
    
    init(networkService: NetworkServicing = NetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    
    // Handle refresh action
    func onRefresh() async {
        page = 0
        
        cancelCurrentTask()
        
        await MainActor.run {
            viewState = .loading
        }
        await fetchProductsFirstPage()
    }
    
    func onAppear() async {
        await fetchProductsFirstPage()
    }
    
    // Detect when the user scrolls near the bottom to trigger loading more product
    func onScrollChange(lastProductId: Int?, currentProductId: Int) async {
        if lastProductId == currentProductId, !isPaginationCompleted {
            await fetchProductsNextPage()
        }
    }
    
    // MARK: - Private Methods
    
    // Cancel any ongoing network task
    private func cancelCurrentTask() {
        currentTask?.cancel()  // Cancel the task if it exists
        currentTask = nil      // Clear the reference to the task
    }
}

extension ProductsListViewModel: ProductsListTransformable {
    private func fetchProductsFirstPage() async {
        // Create and store a new task for fetching the first page
        currentTask = Task {
            // Check for cancellation at the beginning
            guard !Task.isCancelled else { return }
            
            await MainActor.run { viewState = .loading }
            
            // Fetch products for the first page
            let result = await networkService.fetchProducts(page: page)
            
            // Handle Result
            await MainActor.run {
                handleFetchProductsFirstPageResult(with: result)
            }
        }
    }
    
    @MainActor
    private func handleFetchProductsFirstPageResult(with result: Result<ProductsContainerModel, ModelLayersError>) {
        switch result {
        case .success(let data):
            // Transform View Data
            guard let viewData = transform(from: data) else {
                self.viewState = .error(message: "Something went wrong\n Can not transform view Data")
                return
            }
            
            // Update the view state to present the products
            self.viewState = .presenting(viewData: viewData)

            // Enable next page fetching
            canFetchNextPage = true
            
        case .failure:
            guard !Task.isCancelled else { return }
            viewState = .error(message: "Something went wrong\nPlease try again.")
        }
    }
    
    func fetchProductsNextPage() async {
        // Create and store a new task for fetching the Next page
        currentTask = Task {
            // Check for cancellation at the beginning
            guard !Task.isCancelled else { return }

            // Block next page fetching until current one completes or we fetched the last page
            guard canFetchNextPage, !isPaginationCompleted else { return }
                     
            // Presents Next Page Loading View
            await MainActor.run {
                isNextPageLoading = true
            }
            
            canFetchNextPage = false
            
            // Ensure the flag is reset after the task finishes
            defer { canFetchNextPage = true }
            
            // Increment the page number to fetch the next set of products
            page += 1

            // Fetch the next page of products
            let result = await networkService.fetchProducts(page: page)
            
            await MainActor.run {
                handleFetchProductsNextPageResult(with: result)
            }
        }
    }
    
    @MainActor
    private func handleFetchProductsNextPageResult(with result: Result<ProductsContainerModel, ModelLayersError>) {
        switch result {
        case .success(let data):
            guard let viewData = transform(from: data) else { return }
            if viewData.isEmpty {
                // If no more data is available, mark pagination as completed
                isPaginationCompleted = true
            }
            
            guard case .presenting(var existingViewData) = viewState else { return }
            
            // Append the new products to the existing list
            existingViewData.append(contentsOf: viewData)
            
            // Update the view state with the combined data
            viewState = .presenting(viewData: existingViewData)
            
            // Hide next page loading view
            isNextPageLoading = false
            
        case .failure(let failure):
            isNextPageLoading = false
            print("Error: \(failure.localizedDescription)")
        }
    }
}
