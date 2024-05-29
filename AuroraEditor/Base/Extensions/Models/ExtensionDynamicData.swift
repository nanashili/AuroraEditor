//
//  ExtensionDynamicData.swift
//  Aurora Editor
//
//  Created by Tihan-Nico Paxton on 2024/05/29.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

class ExtensionDynamicData: ObservableObject {
    @Published
    public var name: String

    @Published
    public var title: String = ""

    @Published
    public var view: AnyView = AnyView(EmptyView())

    init() {
        self.name = ""
        self.title = ""
        self.view = AnyView(EmptyView())
    }
}
