//
//  ExtensionInstallationViewModel.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 8.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import Combine

/// View model for extension installation.
final class ExtensionInstallationViewModel: ObservableObject {
    /// State of the view model.
    enum State {
        /// Loading state.
        case loading

        /// Error state.
        case error

        /// Success state.
        case success
    }

    /// State of the view model.
    @Published
    var state: State = .loading

    /// Extensions.
    @Published
    var extensions: [Plugin] = []

    /// Initialize a new extension installation view model.
    /// 
    /// - Returns: a new extension installation view model.
    init() {
        fetchExtensions()
    }

    /// Fetch extensions.
    func fetchExtensions() {
        AuroraNetworking().request(baseURL: Constants.auroraEditorBaseURL,
                                   path: Constants.extensions,
                                   useAuthType: .none,
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { completion in
            switch completion {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    guard let extensions = try decoder.decode([Plugin]?.self, from: data) else {
                        Log.debug(
                            "Error: Unable to decode \(String(data: data, encoding: .utf8) ?? "")"
                        )
                        DispatchQueue.main.async {
                            self.state = .error
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.state = .success
                        self.extensions = extensions
                    }
                } catch {
                    Log.fault("\(error)")
                }
            case .failure(let failure):
                self.state = .error
                Log.fault("\(failure)")
            }

        })
    }

    /// Download extension.
    /// 
    /// - Parameter extensionId: the extension id
    func downloadExtension(extensionId: String) {
        AuroraNetworking().request(baseURL: Constants.auroraEditorBaseURL,
                                   path: Constants.downloadExtension(extensionId: extensionId),
                                   useAuthType: .none,
                                   method: .GET,
                                   parameters: nil,
                                   completionHandler: { completion in
            switch completion {
            case .success(let success):
                Log.debug("\(String(data: success, encoding: .utf8) ?? "")")
            case .failure(let failure):
                Log.debug("\(failure)")
            }

        })
    }

}
