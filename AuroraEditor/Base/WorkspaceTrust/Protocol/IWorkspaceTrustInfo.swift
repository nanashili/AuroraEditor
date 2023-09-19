//
//  IWorkspaceTrustInfo.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

public class IWorkspaceTrustInfo: Codable {
    var uriTrustInfo: [IWorkspaceTrustUriInfo]

    init(uriTrustInfo: [IWorkspaceTrustUriInfo]) {
        self.uriTrustInfo = uriTrustInfo
    }
}
