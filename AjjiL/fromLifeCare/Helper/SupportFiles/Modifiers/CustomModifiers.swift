//Proffer
//CustomModifiers.swift

//Created by: M.Magdy on2/26/24                      
//

import SwiftUI

// Scroll detection helper extension
extension ScrollView {
    func onScrollToEnd(perform action: @escaping () -> Void) -> some View {
        GeometryReader { proxy in
            ScrollViewReader { reader in
              self.background(
                Color.clear
                  .onAppear {
                    if proxy.frame(in: .global).maxY < UIScreen.main.bounds.height {
                      action()
                    }
                  }
              )
            }
        }
    }
}

struct ScrollOffsetModifier: ViewModifier {
    let onScrollToEnd: () -> Void

    func body(content: Content) -> some View {
        GeometryReader { proxy in
          content
            .onAppear {
              let offset = proxy.frame(in: .global).maxY
              let screenHeight = UIScreen.main.bounds.height

              if offset < screenHeight {
                onScrollToEnd()
              }
            }
        }
    }
}

extension View {
    func onScrollToEnd(perform action: @escaping () -> Void) -> some View {
        self.modifier(ScrollOffsetModifier(onScrollToEnd: action))
    }
}
