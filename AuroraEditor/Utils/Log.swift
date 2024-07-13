//
//  Log.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 22/02/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI
import os

@available(*, deprecated, message: "Use OSLog `Loger(...,...)` instead", renamed: "self.logger")
/// Aurora Editor logger
///
/// Logger configuration:\
/// subsystem: com.auroraeditor\
/// category: Aurora Editor
let Log = Logger( // swiftlint:disable:this identifier_name
    subsystem: "com.auroraeditor",
    category: "Aurora Editor"
)

extension View {
    /// Log
    /// This enables:
    ///
    ///  ```swift
    ///  SomeSwiftUIView()
    ///  .log {
    ///    // Code you need to run
    ///  }
    ///  ```
    ///
    /// - Parameter closure: Code need to run
    /// - Returns: self
    func log(_ closure: () -> Void) -> some View {
        _ = closure()
        return self
    }
}
