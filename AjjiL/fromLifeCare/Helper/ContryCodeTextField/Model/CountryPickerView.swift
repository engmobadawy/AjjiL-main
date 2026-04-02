////
////  CountryPickerView.swift
////  LifeCare
////
////
////  Created by AMNY on 13/04/2025.
////  Copyright © 2025 M.Magdy. All rights reserved.
////
//
//import SwiftUI
//struct CountryCodePicker: View {
//    @Binding var selectedCountry: Country
//    @State private var searchText = ""
//    @Environment(\.dismiss) private var dismiss
//    
//    let countries = loadCountries()
//    
//    var filteredCountries: [Country] {
//        if searchText.isEmpty {
//            return countries
//        }
//        return countries.filter { country in
//            let isArabic = Locale.current.language.languageCode?.identifier == "ar"
//            let nameToSearch = isArabic ? country.name_ar ?? country.name : country.name
//            return nameToSearch.localizedCaseInsensitiveContains(searchText) || country.dial_code.contains(searchText)
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                SearchBarText(text: $searchText, placeholder: "Search_country".localized())
//                
//                List(filteredCountries) { country in
//                    HStack {
//                        // You can customize flag rendering here
//                        Image(country.code) // Or use images from assets if needed
//                            .frame(width: 30)
//                        
//                        Text(Constants.shared.isAR ? (country.name_ar ?? country.name) : country.name)
//                        
//                        Spacer()
//                        
//                        Text(country.dial_code)
//                    }
//                    .contentShape(Rectangle())
//                    .listRowBackground(
//                        selectedCountry.code == country.code ? Color.primary2A3C90.opacity(0.1) : Color.clear
//                    )
//                    .onTapGesture {
//                        selectedCountry = country
//                        dismiss()
//                    }
//                }
//                .listStyle(PlainListStyle())
//            }
//            .navigationTitle("Select_Country".localized())
//            .navigationBarTitleDisplayMode(.inline)
//            .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
//        }
//    }
//}
//
//
//struct SearchBarText: View {
//    @Binding var text: String
//    var placeholder: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//            
//            TextField(placeholder, text: $text)
//                .textFieldStyle(PlainTextFieldStyle())
//            
//            if !text.isEmpty {
//                Button(action: {
//                    text = ""
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.gray)
//                }
//            }
//        }
//        .padding(8)
//        .background(Color(.systemGray5))
//        .cornerRadius(8)
//        .padding(.horizontal)
//    }
//}
