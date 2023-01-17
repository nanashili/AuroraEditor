//
//  EditorPreferences.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {

    struct EditorPreferences: Codable {

        public var disableWorkspaceTrust: Bool = true

        public init() {}

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.disableWorkspaceTrust = try container.decodeIfPresent(
                Bool.self,
                forKey: .disableWorkspaceTrust
            ) ?? true
        }
    }
}
