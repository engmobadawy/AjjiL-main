//
//  OrdersView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI

// MARK: - Helper Types

enum ActiveSheet: String, Identifiable {
    case filter
    var id: String { rawValue }
}

/// Bundles the dependencies required to trigger a network fetch into a single Equatable type.
private struct FilterTaskID: Equatable {
    let tab: OrdersTab
    let storeName: String
    let date: Date? // UPDATE: Now matches the appliedOrderDate type
}

// MARK: - Main View

struct OrdersView: View {
    @State private var selectedTab: OrdersTab = .currentOrders
    @State private var activeSheet: ActiveSheet?
    @State private var selectedOrderId: Int?
    
    // State initialization for view models
    @State private var filterStore = OrderFilterViewModel()
    @State private var viewModel: OrdersViewModel

    init(viewModel: OrdersViewModel) {
        self.viewModel = viewModel
    }
    
    // Computes the current state of filters and selected tab to drive the .task(id:) modifier
    private var currentTaskID: FilterTaskID {
        FilterTaskID(
            tab: selectedTab,
            storeName: filterStore.appliedStoreName,
            date: filterStore.appliedOrderDate
        )
    }
    
    var body: some View {
        NavigationStack{
        VStack(spacing: 0) {
            
            TopRowNotForHome(
                title: "My Orders",
                showBackButton: false,
                kindOfTopRow: .filter,
                onFilter: {
                    filterStore.loadDrafts() // Prep the draft data before showing
                    activeSheet = .filter    // Trigger the sheet
                }
            )
            
            OrdersTabBar(selectedTab: $selectedTab)
            
            ScrollView {
                VStack(spacing: 0) {
                    switch selectedTab {
                    case .currentOrders: currentOrdersState
                    case .history: historyState
                    }
                }
            }
            .scrollIndicators(.hidden)
            // Automatic fetching whenever the tab or applied filters change
            .task(id: currentTaskID) {
                // Convert empty strings to nil for the API request
                let search = filterStore.appliedStoreName.isEmpty ? nil : filterStore.appliedStoreName
                
                // UPDATE: Format Date? to String? for the ViewModel
                var dateString: String? = nil
                if let dateToFetch = filterStore.appliedOrderDate {
                    dateString = dateToFetch.formatted(
                        .iso8601
                            .year()
                            .month()
                            .day()
                            .dateSeparator(.dash)
                    )
                }
                
                if selectedTab == .history {
                    await viewModel.fetchHistory(storeName: search, date: dateString)
                } else if selectedTab == .currentOrders {
                    await viewModel.fetchCurrentOrders(storeName: search, date: dateString)
                }
            }
        }.navigationDestination(item: $selectedOrderId) { id in
            let repo = OrdersRepositoryImp(networkService: NetworkService())
            let useCase = GetOrderDetailsUC(repo: repo)
            let detailsViewModel = OrderDetailsViewModel(getOrderDetailsUC: useCase)
            
            OrderDetailsView(orderId: id, viewModel: detailsViewModel)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .filter:
                OrdersFilterView(filterViewModel: filterStore)
                    .presentationDetents([.fraction(0.65), .large])
                    .presentationDragIndicator(.hidden)
            }
        }
        } .navigationBarBackButtonHidden(true)
}
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var currentOrdersState: some View {
        if viewModel.isLoadingCurrent && viewModel.currentOrders.isEmpty {
            ProgressView()
                .controlSize(.large)
                .tint(.brandGreen)
                .containerRelativeFrame(.vertical)
            
        } else if !viewModel.currentOrders.isEmpty {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.currentOrders) { order in
                    OrderHistoryCell(
                        config: viewModel.mapToConfig(order),
                        onViewOrder: { selectedOrderId = order.id },
                        onReturn: { print("Tapped Return for \(order.referenceNo)") }
                    )
                }
            }
            .padding()
            
        } else {
            EmptyStateView(
                iconName: "ordersCar",
                title: "No orders yet",
                subtitle: "Hit the orange button down\nbelow to Create an order",
                buttonTitle: "Start Ordering"
            ) { }
            .containerRelativeFrame(.vertical)
        }
    }
    
    @ViewBuilder
    private var historyState: some View {
        if viewModel.isLoadingHistory && viewModel.historyOrders.isEmpty {
            ProgressView()
                .controlSize(.large)
                .tint(.brandGreen)
                .containerRelativeFrame(.vertical)
            
        } else if !viewModel.historyOrders.isEmpty {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.historyOrders) { order in
                    OrderHistoryCell(
                        config: viewModel.mapToConfig(order),
                        onViewOrder: { selectedOrderId = order.id },
                        onReturn: { print("Tapped Return for \(order.referenceNo)") }
                    )
                }
            }
            .padding()
            
        } else {
            EmptyStateView(
                iconName: "calendar",
                title: "No history yet",
                subtitle: "Hit the orange button down\nbelow to Create an order",
                buttonTitle: "Start Ordering"
            ) { }
            .containerRelativeFrame(.vertical)
        }
    }
}

// MARK: - Reusable Empty State View

struct EmptyStateView: View {
    let iconName: String
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 106, height: 106)
                .foregroundStyle(Color.gray.opacity(0.5))
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity)
            }
            .background(Color.brandGreen)
            .clipShape(.rect(cornerRadius: 12))
            .padding(.top, 16)
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 32)
    }
}
