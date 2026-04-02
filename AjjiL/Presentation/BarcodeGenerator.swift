//
//  BarcodeGenerator.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 11/03/2026.
//


import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - Barcode Generator
enum BarcodeGenerator {
    private static let context = CIContext()
    // Explicitly use the Code 128 generator for the typed `message` property
    private static let filter = CIFilter.code128BarcodeGenerator()
    
    /// Generates a Code 128 barcode UIImage from a string
    static func generate(from string: String) -> UIImage? {
        guard !string.isEmpty else { return nil }
        
        // This is now perfectly type-safe
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        
        return nil
    }
}
