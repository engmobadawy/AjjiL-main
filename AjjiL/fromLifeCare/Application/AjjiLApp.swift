import SwiftUI
import UIKit
import MOLH
import Firebase
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MOLHResetable {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        // 1. Initialize custom configurations here
        configureAppServices()
        
        // 2. Initialize window only once
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // 3. Set initial view
        reset()
        
        return true
    }
    
    private func configureAppServices() {
        print("⚙️ Configuring App Services...")
        
    
        languageConfiguration()
//        configureKeyboardManager()
    }
    
    // MARK: - Localization
    func languageConfiguration() {
        let currentDeviceLanguage = NSLocale.current.language.languageCode?.identifier
        print("Current device language: \(currentDeviceLanguage ?? "en")")
        MOLHLanguage.setDefaultLanguage("en")
        MOLH.shared.activate(true)
    }
    
    
    
    func reset() {
        guard let window = self.window else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            guard let newWindow = self.window else { return }
            setupRootView(for: newWindow)
            return
        }
        
        setupRootView(for: window)
    }
    
    private func setupRootView(for window: UIWindow) {
        
        let token = GenericUserDefault.shared.getValue(Constants.shared.token) as? String ?? ""
        let onBoarding = GenericUserDefault.shared.getValue(Constants.shared.onboarding) as? Bool ?? false
        let passwordChanged = GenericUserDefault.shared.getValue(Constants.shared.passwordChanged) as? Bool ?? false
        let resetLanguage = GenericUserDefault.shared.getValue(Constants.shared.resetLanguage) as? Bool ?? false
        let pressSkip = GenericUserDefault.shared.getValue("pressSkip") as? Bool ?? false
        
        
        // Debug logging
        print("🔍 App State Debug:")
        print("Onboarding completed: \(onBoarding)")
        print("Token: \(token)")
        
        // Determine root view based on user state
        let rootView: AnyView
        
        
        
        if !token.isEmpty  {
            // User is logged in and profile is complete - show main app
            print("✅ Navigating to TabBarView")
            rootView = AnyView(/*NavigationStack {*/ TabBarView() /*}*/)
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
        }
        else if !onBoarding && !passwordChanged {
            // First time user - show welcome/onboarding
            print("✅ Navigating to WelcomeView")
            rootView = AnyView(OnBoardingView(window: window))
        } else if passwordChanged && !resetLanguage {
            print("✅ Navigating to LoginView")
            rootView = AnyView(LogInView())
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
            UserDefaults.standard.set(false, forKey: Constants.shared.passwordChanged)
        }else if pressSkip {
            print("✅ Navigating to HomeView as a guest ya bro")
            rootView = AnyView(TabBarView())
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
            UserDefaults.standard.set(false, forKey: Constants.shared.passwordChanged)
        }
        else {
            // User needs to login
            print("✅ Navigating to LoginView")
            rootView = AnyView(LogInView())
            UserDefaults.standard.set(false, forKey: Constants.shared.resetLanguage)
            UserDefaults.standard.set(false, forKey: Constants.shared.passwordChanged)
        }
        
        
        
        
        // Create hosting controller with language environments
        // Create hosting controller with language environments
        let hostingController = UIHostingController(
            rootView: rootView
                .id(UUID()) // 👈 ADD THIS EXACT LINE
                .environment(\.locale, Locale(identifier: Constants.shared.isAR ? "ar" : "en"))
                .environment(\.layoutDirection, Constants.shared.isAR ? .rightToLeft : .leftToRight)
        )
        
        // Set root view controller with smooth transition
        if window.rootViewController != nil {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = hostingController
            })
        } else {
            let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
            let launchViewController = storyboard.instantiateInitialViewController()
            window.rootViewController = launchViewController
            window.makeKeyAndVisible()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = hostingController
                })
            }
        }
        
        window.makeKeyAndVisible()
    }
    
    // MARK: - Deep Link Handling
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        deepLink(url: incomingURL)
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        deepLink(url: url)
        return true
    }
    
    func deepLink(url: URL) {
        let strURL = String(describing: url)
        print("🔗 Deep link received: \(strURL)")
        // Add your specific Deep Link parsing logic here
    }
    
    // MARK: - Application Lifecycle
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}
    
    // MARK: - Push Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(tokenString)")
        // Save token to GenericUserDefault
        // GenericUserDefault.shared.setValue(tokenString, Constants.shared.deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("📬 Received remote notification: \(userInfo)")
        completionHandler(.newData)
    }
}
