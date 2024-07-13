//
//  Bundle.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 01.05.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import OSLog

public extension Bundle {

    /// Returns the main bundle's version string if available (e.g. 1.0.0)
    static var versionString: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    /// Returns the main bundle's build string if available (e.g. 123)
    static var buildString: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    }

    /// Returns the main bundle's commitHash string if available (e.g. 7dbca499d2ae5e4a6d674c6cb498a862e930f4c3)
    static var commitHash: String? {
        guard let path = Bundle.main.url(forResource: "", withExtension: "githash"),
              let data = try? Data(contentsOf: path) else {
            /// Logger
            let logger = Logger(subsystem: "com.auroraeditor", category: "Bundle")

            logger.fault("Failed to get latest commit data.")
            return nil
        }

        return String(decoding: data, as: UTF8.self)
    }
}

extension Bundle {
    /// Returns the bundle for the AuroraEditor module
    static var module: Bundle {
        guard let bundle = Bundle(identifier: "com.auroraeditor") else {
            fatalError("Failed to get bundle!")
        }

        return bundle
    }
}
