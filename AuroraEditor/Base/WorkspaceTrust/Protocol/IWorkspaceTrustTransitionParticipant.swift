//
//  IWorkspaceTrustTransitionParticipant.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/12/20.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

protocol IWorkspaceTrustTransitionParticipant {
    func participate(trusted: Bool)
}
