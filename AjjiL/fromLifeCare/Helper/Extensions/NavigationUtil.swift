////  LifeCare
////
////NavigationUtil.swift
//
////Created by: M.Magdy on 5/5/25.
////
//
//import UIKit
//import SwiftUI
//
//struct NavigationUtil {
//    static func popToRootView() {
//      findNavigationController(viewController: UIApplication.shared.currentUIWindow()?.rootViewController)?
//            .popToRootViewController(animated: true)
//    }
//
//  static func navigateToSpecificTabBar(_ index: Int) {
//    guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
//      return
//    }
//
//    guard let firstWindow = firstScene.windows.first else {
//      return
//    }
//    firstWindow.rootViewController = UIHostingController(rootView: TabBarView())
//    firstWindow.makeKeyAndVisible()
//  }
//
//  static func navigateToSecondViewController() {
//    guard let navigationController = findNavigationController(viewController: UIApplication.shared.currentUIWindow()?.rootViewController),
//          let secondViewController = navigationController.viewControllers[safe: 1] else {
//      return
//    }
//
//    navigationController.popToViewController(secondViewController, animated: true)
//  }
//
//  static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
//    guard let viewController = viewController else {
//      return nil
//    }
//    if let navigationController = viewController as? UINavigationController {
//      return navigationController
//    }
//    for childViewController in viewController.children {
//      return findNavigationController(viewController: childViewController)
//    }
//    return nil
//  }
//
//}
//
//public extension UIApplication {
//    func currentUIWindow() -> UIWindow? {
//        let connectedScenes = UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .compactMap { $0 as? UIWindowScene }
//
//        let window = connectedScenes.first?
//            .windows
//            .first { $0.isKeyWindow }
//
//        return window
//
//    }
//}
//
//extension Array {
//    subscript(safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil
//    }
//}
