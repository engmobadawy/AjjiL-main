//
//  no.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 01/03/2026.
//

import SwiftUI
extension Binding where Value == String {
    var noSpaces: Binding<String> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0.replacingOccurrences(of: " ", with: "") }
        )
    }
}
