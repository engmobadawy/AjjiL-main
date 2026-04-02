//
//  LocationManager.swift
//  lifeCare
//
//  Created by AMNY on 31/05/2025.
//



import Foundation
import CoreLocation
import Combine


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
        
        // DEBUG: Print all Info.plist keys
        print("📋 All Info.plist keys:")
        if let infoDict = Bundle.main.infoDictionary {
            for (key, value) in infoDict {
                if key.contains("Location") {
                    print("  ✓ \(key) = \(value)")
                }
            }
        }
        
        // Check specifically for our key
        if let desc = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") {
            print("✅ Found location key: \(desc)")
        } else {
            print("❌ NSLocationWhenInUseUsageDescription NOT FOUND")
            print("📁 Info.plist path: \(Bundle.main.path(forResource: "Info", ofType: "plist") ?? "unknown")")
        }
    }

    func requestLocationOnce() {
        isLoading = true
        
        // Debug: Check if key exists
        if let description = Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String {
            print("✅ Info.plist key found: \(description)")
        } else {
            print("❌ Info.plist key NOT found!")
        }
        
        let status = locationManager.authorizationStatus
        print("🔍 Location Status: \(status.rawValue) (\(statusString(status)))")
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Authorized - requesting location")
            locationManager.requestLocation()
            
        case .notDetermined:
            print("❓ Not determined - requesting authorization")
            print("📱 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
            
            // Force request
            DispatchQueue.main.async {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
        case .denied:
            print("❌ Denied")
            isLoading = false
            useDefaultLocation()
            
        case .restricted:
            print("🔒 Restricted")
            isLoading = false
            useDefaultLocation()
            
        @unknown default:
            print("⚠️ Unknown status")
            isLoading = false
            useDefaultLocation()
        }
        
        // Safety timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) { [weak self] in
            guard let self = self else { return }
            if self.isLoading && self.currentLocation == nil {
                print("⏱️ Timeout - using default location")
                self.isLoading = false
                self.useDefaultLocation()
            }
        }
    }

    private func statusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
    
    private func useDefaultLocation() {
        print("📍 Using default location")
        currentLocation = CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            print("🔄 Authorization changed to: \(manager.authorizationStatus.rawValue) (\(self.statusString(manager.authorizationStatus)))")
            
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                print("✅ Now authorized - requesting location")
                manager.requestLocation()
            } else if manager.authorizationStatus == .denied ||
                      manager.authorizationStatus == .restricted {
                self.isLoading = false
                self.errorMessage = "Location access denied"
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("⚠️ No location in array")
            return
        }
        
        print("✅ Got location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.isLoading = false
            self.errorMessage = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            self.useDefaultLocation()
        }
    }
}
