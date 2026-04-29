//
//  OrdersView.swift
//  AjjiLMB
//
//  Created by mohamed mahmoud sobhy badawy on 23/03/2026.
//

import SwiftUI
import Shimmer

// MARK: - Helper Types

enum ActiveSheet: String, Identifiable {
    case filter
    var id: String { rawValue }
}

private struct FilterTaskID: Equatable {
    let tab: OrdersTab
    let storeName: String
    let date: Date?
}

enum OrderDestination: Hashable {
    case details(id: Int, isHistory: Bool)
    case cashierScan(orderId: Int, qrCode: String, points: Int)
}

// MARK: - Main View

struct OrdersView: View {
    @Environment(TabBarVisibility.self) private var tabVisibility
    @State private var selectedTab: OrdersTab = .currentOrders
    @State private var activeSheet: ActiveSheet?
    
    @State private var navigationDestination: OrderDestination?
    
    @State private var filterStore = OrderFilterViewModel()
    @State private var viewModel: OrdersViewModel

    init() {
        let repo = OrdersRepositoryImp(networkService: NetworkService())
        let vm = OrdersViewModel(
            getOrderHistoryUC: GetOrderHistoryUC(repo: repo),
            getCurrentOrdersUC: GetCurrentOrdersUC(repo: repo),
            getQRCodeUC: GetQRCodeUC(repo: repo)
        )
        self._viewModel = State(initialValue: vm)
    }
    
    private var currentTaskID: FilterTaskID {
        FilterTaskID(
            tab: selectedTab,
            storeName: filterStore.appliedStoreName,
            date: filterStore.appliedOrderDate
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TopRowNotForHome(
                    title: "My Orders".newlocalized,
                    showBackButton: false,
                    kindOfTopRow: .filter,
                    onFilter: {
                        filterStore.loadDrafts()
                        activeSheet = .filter
                    }
                )
                
                OrdersTabBar(selectedTab: $selectedTab)
                
                ScrollView {
                    VStack(spacing: 0) {
                        if Constants.isGuestMode {
                            guestModeState
                        } else {
                            switch selectedTab {
                            case .currentOrders: currentOrdersState
                            case .history: historyState
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .task(id: currentTaskID) {
                    await fetchOrders()
                }
                .overlay {
                    if viewModel.isFetchingQR {
                        VStack(spacing: 12) {
                            ProgressView()
                                .controlSize(.large)
                            Text("Generating Code...".newlocalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(24)
                        .background(.regularMaterial)
                        .clipShape(.rect(cornerRadius: 16))
                    }
                }
            }
            .onAppear {
                Task { await fetchOrders() }
            }
            .navigationDestination(item: $navigationDestination) { destination in
                switch destination {
                case .details(let id, let isHistory):
                    let repo = OrdersRepositoryImp(networkService: NetworkService())
                    let detailsViewModel = OrderDetailsViewModel(getOrderDetailsUC: GetOrderDetailsUC(repo: repo))
                    OrderDetailsView(orderId: id, isHistoryOrder: isHistory, viewModel: detailsViewModel)
                    
                case .cashierScan(let id, let qrCode, let points):
                    CashierScanView(orderId: id, qrCode: qrCode, points: points)
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .filter:
                    OrdersFilterView(filterViewModel: filterStore)
                        .presentationDetents([.fraction(0.65), .large])
                        .presentationDragIndicator(.hidden)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Actions
    
    private func fetchOrders() async {
        guard !Constants.isGuestMode else { return }
        
        let search = filterStore.appliedStoreName.isEmpty ? nil : filterStore.appliedStoreName
        var dateString: String? = nil
        if let dateToFetch = filterStore.appliedOrderDate {
            dateString = dateToFetch.formatted(.iso8601.year().month().day().dateSeparator(.dash))
        }
        
        if selectedTab == .history {
            await viewModel.fetchHistory(storeName: search, date: dateString)
        } else {
            await viewModel.fetchCurrentOrders(storeName: search, date: dateString)
        }
    }
    
    private func handleCashierScan(for orderId: Int) {
        Task {
            if let qrData = await viewModel.fetchQRCode(for: orderId) {
                navigationDestination = .cashierScan(
                    orderId: orderId,
                    qrCode: qrData.qrcode,
                    points: qrData.points
                )
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var guestModeState: some View {
        EmptyStateView(
            iconName: "ordersCar",
            title: "No orders yet".newlocalized,
            subtitle: "Login To start your order".newlocalized,
            buttonTitle: "Log In".newlocalized,
            action: {
                UserDefaults.standard.set(false, forKey: "pressSkip".newlocalized)
                Constants.isGuestMode = false
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.reset()
                }
            }
        )
        .containerRelativeFrame(.vertical)
    }
    
    @ViewBuilder
    private var currentOrdersState: some View {
        if viewModel.isLoadingCurrent && viewModel.currentOrders.isEmpty {
            OrdersListSkeleton().shimmering()
        } else if !viewModel.currentOrders.isEmpty {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.currentOrders) { order in
                    OrderHistoryCell(
                        config: viewModel.mapToConfig(order, isHistory: false),
                        onViewOrder: {
                            navigationDestination = .details(id: order.id, isHistory: false)
                        },
                        onReturn: { },
                        onCashierScan: {
                            handleCashierScan(for: order.id)
                        }
                    )
                }
            }
            .padding()
            
        } else {
            EmptyStateView(
                iconName: "ordersCar",
                title: "No orders yet".newlocalized,
                subtitle: "Hit the orange button down\nbelow to Create an order".newlocalized,
                buttonTitle: "Start Ordering".newlocalized
            ) { }
            .containerRelativeFrame(.vertical)
        }
    }
    
    @ViewBuilder
    private var historyState: some View {
        if viewModel.isLoadingHistory && viewModel.historyOrders.isEmpty {
            OrdersListSkeleton().shimmering()
        } else if !viewModel.historyOrders.isEmpty {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.historyOrders) { order in
                    OrderHistoryCell(
                        config: viewModel.mapToConfig(order, isHistory: true),
                        onViewOrder: {
                            navigationDestination = .details(id: order.id, isHistory: true)
                        },
                        onReturn: {
                            print("Tapped Return for \(order.referenceNo)")
                        },
                        onCashierScan: { }
                    )
                }
            }
            .padding()
            
        } else {
            EmptyStateView(
                iconName: "calendar",
                title: "No history yet".newlocalized,
                subtitle: "Hit the orange button down\nbelow to Create an order".newlocalized,
                buttonTitle: "Start Ordering".newlocalized
            ) { }
            .containerRelativeFrame(.vertical)
        }
    }
}

// MARK: - Skeleton Loading View

struct OrdersListSkeleton: View {
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { _ in
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 140, height: 16)
                                .clipShape(.rect(cornerRadius: 4))
                            
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .frame(width: 80, height: 14)
                                .clipShape(.rect(cornerRadius: 4))
                        }
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 70, height: 24)
                            .clipShape(.capsule)
                    }
                    
                    Divider()
                    
                    HStack {
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 100, height: 14)
                            .clipShape(.rect(cornerRadius: 4))
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: 90, height: 32)
                            .clipShape(.capsule)
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
        .padding()
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
            .background(Color(red: 0.16, green: 0.53, blue: 0.38))
            .clipShape(.rect(cornerRadius: 12))
            .padding(.top, 16)
            .padding(.horizontal, 40)
        }
        .padding(.horizontal, 32)
    }
}
