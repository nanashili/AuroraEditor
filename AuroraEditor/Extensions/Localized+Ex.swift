//
//  Localized+ex.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 20/01/2023.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

extension String {
    @available(*, deprecated, message: "Use built-in localization instead.")
    /// Localize a string
    /// - Parameter comment: The comment
    /// - Returns: The localized string
    func localize(comment: String = "") -> String {
        let defaultLanguage = "en"
        let value = NSLocalizedString(self, comment: comment)
        if value != self || NSLocale.preferredLanguages.first == defaultLanguage {
            return value // String localization was found
        }

        // Load resource for default language to be used as
        // the fallback language
        guard let path = Bundle.main.path(forResource: defaultLanguage, ofType: "lproj"),
                let bundle = Bundle(path: path) else {
            return value
        }

        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    /// Localize a string
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
    }

    /// Localize a string with arguments
    func localized(_ args: CVarArg...) -> String {
        return String(format: localized, arguments: args)
    }
}