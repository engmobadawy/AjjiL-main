//  LifeCare
//
//Optional + Extension.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation

extension Optional where Wrapped == String {
    func orWhenNilOrEmpty(_ defaultValue: String) -> String {
        switch self {
        case .none:
            return defaultValue
        case .some(let value) where value.isEmpty:
            return defaultValue
        case .some(let value):
            return value
        }
    }
}
