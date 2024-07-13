//
//  ExploreItemView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/10/29.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

/// Explore item view.
struct ExploreItemView: View {

    /// The extension data.
    @State
    var extensionData: Plugin

    /// Extensions model
    @State
    var extensionsModel: ExtensionInstallationViewModel

    /// The view body.
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: "\(extensionData.extensionImage)")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8
                            )
                        )
                        .accessibilityLabel(Text("Extension Icon"))
                } else if phase.error != nil {
                    Image(systemName: "lasso")
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8
                            )
                        )
                        .accessibilityLabel(Text("Extension Icon"))
                } else {
                    Image(systemName: "lasso")
                        .frame(width: 36, height: 36)
                        .background(.blue)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 8
                            )
                        )
                        .accessibilityLabel(Text("Extension Icon"))
                }
            }

            VStack(alignment: .leading) {
                Text(extensionData.extensionName)
                    .font(.system(size: 13))
                    .fontWeight(.medium)

                Text(extensionData.extensionDescription)
                    .font(.system(size: 11))
                    .truncationMode(.tail)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(minWidth: 87)

            Button {
                extensionsModel.downloadExtension(extensionId: extensionData.id.uuidString)
            } label: {
                Text("GET")
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.bordered)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 40
                )
            )
        }
    }
}
