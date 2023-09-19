//
//  PrivacySecurityPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/18.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {

    /// The global settings for the terminal emulator
    struct PrivacySecurityPreferences: Codable {

        public var trustNotification: TrustNotifications = .untilDismissed

        public var untrustedFileAction: UntrustedFileAction = .open

        public var startupAction: StartupAction = .once

        public var trustEmptyWorkspace: Bool = false

        public var trustedWorkspaces: [IWorkspaceTrustInfo] = []

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.trustNotification = try container.decodeIfPresent(TrustNotifications.self,
                                                                   forKey: .trustNotification) ?? .untilDismissed
            self.untrustedFileAction = try container.decodeIfPresent(UntrustedFileAction.self,
                                                                     forKey: .untrustedFileAction) ?? .open
            self.startupAction = try container.decodeIfPresent(StartupAction.self,
                                                               forKey: .startupAction) ?? .once
            self.trustEmptyWorkspace = try container.decodeIfPresent(Bool.self,
                                                               forKey: .trustEmptyWorkspace) ?? false
            self.trustedWorkspaces = try container.decodeIfPresent([IWorkspaceTrustInfo].self,
                                                                   forKey: .trustedWorkspaces) ?? []
        }
    }
}

public enum TrustNotifications: String, Codable, CaseIterable {
    case untilDismissed = "Until Dismissed"
    case always = "Always"
    case never = "Never"
}

public enum UntrustedFileAction: String, Codable, CaseIterable {
    case open = "Open"
    case prompt = "Prompt"
    case newWindow = "New Window"
}

public enum StartupAction: String, Codable, CaseIterable {
    case once = "Once"
    case always = "Always"
    case never = "Never"
}
