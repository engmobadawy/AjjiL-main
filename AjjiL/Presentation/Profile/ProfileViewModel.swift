//
//  ProfileViewModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//
import SwiftUI
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    // MARK: - State Properties
    var profile: ProfileEntity?
    var profileImage: UIImage? 
    var isLoading: Bool = false
    var errorMessage: String?
    
    // MARK: - Dependencies
    private let getProfileUC: GetProfileUC
    
    init(getProfileUC: GetProfileUC) {
        self.getProfileUC = getProfileUC
    }
    
    /// Fetches user profile data from the backend.
    /// - Parameter forceRefresh: If true, bypasses the local cache check to fetch fresh data.
    func fetchProfile(forceRefresh: Bool = false) async {
        // Only skip if we already have data and are NOT forcing a refresh
        if !forceRefresh {
            guard profile == nil else { return }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await getProfileUC.execute()
            
            // Fetch and downsample the image immediately after the profile entity loads
            if let photoURLString = profile?.photoURL, let url = URL(string: photoURLString) {
                await fetchAndDownsampleImage(from: url)
            }
        } catch let error as DecodingError {
            handleDecodingError(error)
        } catch {
            print("❌ General Error: \(error)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Image Optimization
    
    /// Downloads and downsamples the profile image to reduce memory footprint.
    private func fetchAndDownsampleImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Standard size for profile avatars in the UI
            let pointSize = CGSize(width: 120, height: 120)
            
            if let downsampled = downsampleImage(data: data, to: pointSize) {
                self.profileImage = downsampled
            } else {
                // Fallback to standard initialization if downsampling fails
                self.profileImage = UIImage(data: data)
            }
        } catch {
            print("❌ Failed to load image data: \(error)")
        }
    }
    
    /// Core logic for creating a thumbnail at a specific size to avoid layout thrash and high memory use.
    private func downsampleImage(data: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else { return nil }
        
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
        return UIImage(cgImage: downsampledImage)
    }

    // MARK: - Error Handling
    
    private func handleDecodingError(_ error: DecodingError) {
        switch error {
        case .typeMismatch(let type, let context):
            let key = context.codingPath.last?.stringValue ?? "unknown"
            print("❌ Type Mismatch: Expected \(type) for key '\(key)'.")
            errorMessage = "Data format error."
        case .keyNotFound(let key, _):
            print("❌ Key Not Found: The key '\(key.stringValue)' is missing.")
            errorMessage = "Missing data error."
        case .valueNotFound(let type, let context):
            let key = context.codingPath.last?.stringValue ?? "unknown"
            print("❌ Value Not Found: Expected \(type) for key '\(key)' but got null.")
            errorMessage = "Null value error."
        case .dataCorrupted(let context):
            print("❌ Data Corrupted: \(context.debugDescription)")
            errorMessage = "Data corrupted."
        @unknown default:
            errorMessage = "An unexpected error occurred."
        }
    }
}
