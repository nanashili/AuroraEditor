//
//  Avatar.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftUI

/// Avatar
class Avatar {
    /// Get Git Avatar
    /// 
    /// - Parameter authorEmail: Author's email
    /// 
    /// - Returns: Avatar image
    public func gitAvatar(authorEmail: String) -> some View {
        let avatarURL = "https://www.gravatar.com/avatar/\(Avatar().generateAvatarHash(authorEmail))"

        return CachingAsyncImageView(avatarURL: avatarURL,
                                     imageSize: 42)
        .frame(width: 42, height: 42)
        .clipShape(Circle())
        .accessibilityLabel("Contributor Avatar")
    }

    /// Get Controbuter Avatar
    /// 
    /// - Parameter contributerAvatarURL: Contributers's avatar url
    /// 
    /// - Returns: Contributer avatar image
    public func contributorAvatar(contributorAvatarURL: String) -> some View {
        CachingAsyncImageView(avatarURL: contributorAvatarURL,
                              imageSize: 42)
            .frame(width: 42, height: 42)
            .clipShape(Circle())
            .accessibilityLabel("Contributor Avatar")
    }

    /// Generate avatar hash
    /// 
    /// - Parameter authorEmail: Author's email address
    /// 
    /// - Returns: Avatar hash
    public func generateAvatarHash(_ authorEmail: String) -> String {
        let hash = authorEmail.md5(trim: true, caseSensitive: false)
        return "\(hash)?d=404&s=84"
    }

    /// Generate (random) avatar color
    /// 
    /// - Parameter authorEmail: Author's email address
    /// 
    /// - Returns: Color
    public func avatarColor(author: String) -> Color {
        let hash = generateAvatarHash(author).hash
        switch hash % 12 {
        case 0: return .red
        case 1: return .orange
        case 2: return .yellow
        case 3: return .green
        case 4: return .mint
        case 5: return .teal
        case 6: return .cyan
        case 7: return .blue
        case 8: return .indigo
        case 9: return .purple
        case 10: return .brown
        case 11: return .pink
        default: return .teal
        }
    }
}
