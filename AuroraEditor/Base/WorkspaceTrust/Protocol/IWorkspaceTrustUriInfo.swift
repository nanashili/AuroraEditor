//
//  IWorkspaceTrustUriInfo.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public class IWorkspaceTrustUriInfo: Codable {
    var uri: URL
    var trusted: Bool

    init(uri: URL,
         trusted: Bool) {
        self.uri = uri
        self.trusted = trusted
    }
}
