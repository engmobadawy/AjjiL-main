//  LifeCare
//
//AppFonts.swift

//Created by: M.Magdy on 5/5/25.
//

import SwiftUI

protocol FontNameProtocol {
  var fontName: String { get }
}

enum Poppins: String, FontNameProtocol {
    case bold = "Bold"
    case extraBold = "ExtraBold"
    case semiBold = "SemiBold"
    case medium = "Medium"
    case light = "Light"
    case extraLight = "ExtraLight"
    case regular = "Regular"
    
    var fontName: String {
      "Poppins-\(self.rawValue.capitalizeFirstLetter)"
    }
}

enum GESSTwo: String, FontNameProtocol {
    case  bold, light, medium

    var fontName: String {
      "GESSTwo\(self.rawValue.capitalizeFirstLetter)-\(self.rawValue.capitalizeFirstLetter)"
    }
}

extension View {
    func textFont(_ font: FontNameProtocol, _ size: CGFloat = 14, _ color: Color = .black) -> some View {
        self.font(.custom(font.fontName, size: Constants.shared.isAR ? size : size)).foregroundStyle(color)
    }
}
