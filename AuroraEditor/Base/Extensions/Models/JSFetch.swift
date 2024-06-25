//
//  JSFetch.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 04/06/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import JavaScriptCore

/// JavaScript `fetch` function
///
/// - Note: Depends on JSPromise.
class JSFetch {
    /// Shared instance so it will not be unloaded.
    static let shared: JSFetch = .init()

    /// Register class into the current JavaScript Context.
    /// - Parameter jsContext: The current JavaScript context.
    func registerInto(jsContext: JSContext) {
        jsContext.setObject(
            unsafeBitCast(fetch, to: JSValue.self),
            forKeyedSubscript: "fetch" as (NSCopying & NSObjectProtocol)
        )
    }

    /// (Obj-C) The fetch function
    let fetch: @convention(block) (String) -> JSPromise? = { link in
        let promise = JSPromise()
        promise.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            timer.invalidate()

            if let url = URL(string: link) {
                URLSession.shared.dataTask(with: url) { (data, _, error) in
                    if let error = error {
                        promise.fail(error: error.localizedDescription)
                    } else if let data = data,
                        let string = String(data: data, encoding: String.Encoding.utf8) {
                        promise.success(value: string)
                    } else {
                        promise.fail(error: "\(url) is empty")
                    }
                }
                .resume()
            } else {
                promise.fail(error: "\(link) is not url")
            }
        }

        return promise
    }
}
