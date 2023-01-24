//
//  LazyView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2023/01/02.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

struct LazyView<Content>: View where Content: View {
    let destination: () -> Content
    var body: some View {
        destination()
    }
}
