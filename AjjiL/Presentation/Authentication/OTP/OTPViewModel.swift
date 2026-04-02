//
//  OTPViewModel.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 17/02/2026.
//
import SwiftUI
import Observation

@Observable
@MainActor
final class OTPViewModel {
    
    // MARK: - Input Fields
    var code = ""
    
    // MARK: - Validation State
    var errorMessage: String?

    // MARK: - Timer State
    var remainingTime = 0
    private var timerTask: Task<Void, Never>?
    
    // MARK: - Derived State
    var isFormReady: Bool {
        code.count >= 4
    }
    
    var isTimerRunning: Bool {
        remainingTime > 0
    }
    
    var formattedTime: String {
        Duration.seconds(remainingTime).formatted(.time(pattern: .minuteSecond))
    }
    
    // MARK: - Logic
    func validate() -> Bool {
        errorMessage = nil
        
        if code != "1234" {
            errorMessage = "Invalid Code".localized()
            return false
        }
        return true
    }

    // Updated to accept the flow parameter
    func verifyCode(for flow: OTPFlow) async -> Bool {
        guard validate() else { return false }
        
        do {
            // Simulate network call
            try await Task.sleep(for: .seconds(1))
            
            // If the user is signing up, save their token so MOLH.reset() navigates to TabBarView
            if flow == .signUp {
                             print("Sign Up OTP verified. Proceeding to Login.")
                        } else {
                            print("Forgot Password OTP verified. Navigating to Forget Password Screen.")
                        }
            
            return true
        } catch {
            return false
        }
    }
    
    func resendCode() {
        code = ""
        errorMessage = nil
        print("Resend code logic triggered")
        startTimer()
    }
    
    // MARK: - Timer Methods
    func startTimer() {
        timerTask?.cancel()
        remainingTime = 60
        
        timerTask = Task {
            while remainingTime > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                remainingTime -= 1
            }
        }
    }
}
