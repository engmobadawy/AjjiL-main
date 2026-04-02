//
//  StoresAvatarView.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 15/03/2026.
//

import SwiftUI

struct StoresAvatarView: View {
    let image: UIImage?
    private let avatarSize: CGFloat = 113

    var body: some View {
        AvatarBaseView(image: image, size: avatarSize)
            .overlay(alignment: .bottomTrailing) {
                EditBadgeView()
                    .alignmentGuide(.trailing) { dimension in dimension.width / 2 }
                    .alignmentGuide(.bottom) { dimension in dimension.height / 2 }
                    .offset(x: -12, y: -12)
            }
    }
}

struct AvatarBaseView: View {
    let image: UIImage?
    let size: CGFloat

    private let backgroundColor = Color(red: 202 / 255.0, green: 251 / 255.0, blue: 242 / 255.0)
    private let borderColor = Color(red: 255 / 255.0, green: 119 / 255.0, blue: 1 / 255.0)

    var body: some View {
        ZStack {
            backgroundColor
            
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("car")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
        }
        .frame(width: size, height: size)
        .clipShape(.circle)
        .overlay {
            Circle()
                .stroke(borderColor, lineWidth: 3)
        }
    }
}

struct EditBadgeView: View {
    private let badgeSize: CGFloat = 38
    private let borderColor = Color(red: 255 / 255.0, green: 119 / 255.0, blue: 1 / 255.0)

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
            
            Circle()
                .stroke(borderColor, lineWidth: 1)
            
            Image("Edit")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(borderColor)
        }
        .frame(width: badgeSize, height: badgeSize)
    }
}
