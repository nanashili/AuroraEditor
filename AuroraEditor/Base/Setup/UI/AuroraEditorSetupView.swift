//
//  AuroraEditorSetupView.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/12/17.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

struct AuroraEditorSetupView: View {
    var body: some View {
        VStack {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.top)

            Text("AuroraEditor")
                .font(.system(size: 26, weight: .light))
                .padding(.top, -10)

            Text("Version \(appVersion) (\(appBuild))")
                .foregroundColor(.secondary)
                .font(.system(size: 11))
                .padding(.top, -10)
                .onHover { inside in
                    if inside {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
                .onTapGesture {
                    copyInformation()
                }

            Text("Select the tools you would like to install:")
                .font(.system(size: 13))
                .padding(.top, 10)

            List {
                AuroraEditorSetupItemView(checked: true,
                                          image: "calendar",
                                          itemName: "Project Planning",
                                          size: "Built-in")
                .disabled(true)

                AuroraEditorSetupItemView(checked: false,
                                          image: "terminal",
                                          itemName: "Cli",
                                          size: "1.2 MB")

                AuroraEditorSetupItemView(checked: false,
                                          image: "source_control",
                                          itemName: "Version Control",
                                          size: "10 MB")
            }
            .frame(height: 150)
            .padding(.horizontal, 45)

            Text("Required additional components will also be installed.")
                .font(.system(size: 13))
                .padding(.top, -10)
                .foregroundColor(.gray)

            Button {
                EditorSetupService().updateEditorUsage(value: true)
            } label: {
                Text("Install")
                    .font(.system(size: 14))
                    .padding()
                    .foregroundColor(.white)
                    .padding()
            }
            .padding(.top)
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(width: 460, height: 490)
    }
}

struct AuroraEditorSetupView_Previews: PreviewProvider {
    static var previews: some View {
        AuroraEditorSetupView()
    }
}
