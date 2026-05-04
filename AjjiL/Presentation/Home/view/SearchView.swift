import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    // Owned state for our observable class
    @State private var historyManager = SearchHistoryManager()
    
    var body: some View {
        VStack(spacing: 0) {
            // Using your existing top row component
            TopRowNotForHome(
                title: "Search".newlocalized,
                showBackButton: true,
                kindOfTopRow: .withNotification, // Adjust enum case based on your needs
                onBack: { dismiss() },
                onCart: { /* Handle Cart */ },
                onNotification: { /* Handle Notification */ }
            )
            
            VStack(spacing: 16) {
                // MARK: Search Bar & Scanner Row
                HStack(spacing: 12) {
                    SearchBarButton(
                        text: $searchText,
                        placeholder: "Search beverages or foods",
                        onSubmit: {
                            performSearch(searchText)
                        }
                    )
                    
                    // Barcode Scanner Button
                    Button {
                        // Navigate to scanner
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 24))
                            .foregroundStyle(.primary)
                            .frame(width: 46, height: 46)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(.black.opacity(0.1), lineWidth: 1)
                            }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                
                // MARK: Recent Searches List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(historyManager.history, id: \.self) { keyword in
                            SearchHistoryRow(
                                keyword: keyword,
                                onSelect: {
                                    searchText = keyword
                                    performSearch(keyword)
                                },
                                onDelete: {
                                    withAnimation(.snappy) {
                                        historyManager.removeSearch(keyword)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
            }
            
            Spacer(minLength: 0)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.white.ignoresSafeArea())
    }
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else { return }
        historyManager.addSearch(query)
        
        // TODO: Call your ViewModel to fetch search results here
        print("Searching for: \(query)")
    }
}

// MARK: - Extracted Row for Fast Diffing
struct SearchHistoryRow: View {
    let keyword: String
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
            
            Text(keyword)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundStyle(.primary)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(12) // Generous hit area for easy tapping
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .contentShape(.rect) // Makes the entire row tappable
        .onTapGesture(perform: onSelect)
    }
}