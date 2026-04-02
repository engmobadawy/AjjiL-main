//  LifeCare
//
//UIApplication+Extension.swift

//Created by: M.Magdy on 5/5/25.
//

import Foundation
import UIKit

extension UIApplication {
    var safeAreaTopInset: CGFloat {
      (connectedScenes
        .compactMap { $0 as? UIWindowScene } // Get UIWindowScene
        .flatMap { $0.windows } // Get all windows in the scene
        .first(where: { $0.isKeyWindow })? // Find the key window
        .safeAreaInsets.top ?? 0)// Access the bottom safe area inset
    }
}

