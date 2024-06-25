//
//  TokenizeResult.swift
//  Aurora Editor
//
//  Created by Matthew Davidson on 4/1/20.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

// TODO: @0xWDG Look if this can be removed.
/// Tokenize result
public struct TokenizeResult {
    /// Line state
    public let state: LineState

    /// Tokenized line
    public let tokenizedLine: TokenizedLine

    /// Matched tokens
    public let matchTokens: [Token]
}
