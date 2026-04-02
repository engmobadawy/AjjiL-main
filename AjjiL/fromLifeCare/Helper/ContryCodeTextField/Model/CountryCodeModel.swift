//
//  CountryCodeModel.swift
//  LifeCare
//
//
//  Created by AMNY on 13/04/2025.
//  Copyright © 2025 M.Magdy. All rights reserved.
//

import Foundation


struct Country: Codable, Identifiable {
    var id: String { code } // for List
    let name: String
    let name_ar: String?
    let dial_code: String
    let code: String
    
static var defaultCountry: Country {
           Country(name: "Saudi Arabia", name_ar: "السعودية", dial_code: "+966", code: "SA")
       }
}

func loadCountries() -> [Country] {
    guard let url = Bundle.main.url(forResource: "country-codes-with-arabic", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let countries = try? JSONDecoder().decode([Country].self, from: data) else {
        return []
    }
    return countries
}

