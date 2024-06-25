//
//  TokenThemeAttribute.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 21/12/19.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
// TODO: @0xWDG Look if this can be removed.
/// HighlightTheme attribute for applying a theme to a single token with a given range.
///
/// - Important: Do not try to configure the `paragraphStyle` attribute, as it may not produce the expected
/// behavior. Instead conform to `LineThemeAttribute`
public protocol TokenThemeAttribute: ThemeAttribute {

    func apply(to attrStr: NSMutableAttributedString, withRange range: NSRange)
}
