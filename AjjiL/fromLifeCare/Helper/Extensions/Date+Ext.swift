//
//  Date+Ext.swift
//  lifeCare
//
//  Created by AMNY on 29/05/2025.
//

import Foundation

extension Date {
    func toString(format: String = "EEEE, MMMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Predefined common formats
    var fullDateString: String {
        toString(format: "EEEE, MMMM d, yyyy")
    }
    
    var shortDateString: String {
        toString(format: "MMM d, yyyy")
    }
    
    var numericDateString: String {
        toString(format: "MM/dd/yyyy")
    }
}
