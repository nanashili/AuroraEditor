//
//  SwiftTerm+Color+Init.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 24.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation
import SwiftTerm

/// SwiftTerm Color extension
internal extension SwiftTerm.Color {
    // 0.0-1.0
    /// Initialize color with red, green and blue values (Double)
    /// 
    /// - Parameter red: red value
    /// - Parameter green: green value
    /// - Parameter blue: blue value
    convenience init(dRed red: Double, green: Double, blue: Double) {
        let multiplier: Double = 65535
        self.init(red: UInt16(red * multiplier),
                  green: UInt16(green * multiplier),
                  blue: UInt16(blue * multiplier))
    }

    // 0-255
    /// Initialize color with red, green and blue values (UInt8)
    /// 
    /// - Parameter red: red value
    /// - Parameter green: green value
    /// - Parameter blue: blue value
    convenience init(iRed red: UInt8, green: UInt8, blue: UInt8) {
        let divisor: Double = 255
        self.init(dRed: Double(red) / divisor,
                  green: Double(green) / divisor,
                  blue: Double(blue) / divisor)
    }

    // 0x000000 - 0xFFFFFF
    /// Initialize color with red, green and blue values
    /// 
    /// - Parameter hex: hex value
    convenience init(hex: Int) {
        let red = UInt8((hex >> 16) & 0xFF)
        let green = UInt8((hex >> 8) & 0xFF)
        let blue = UInt8(hex & 0xFF)
        self.init(iRed: red, green: green, blue: blue)
    }

    /// 0x000000 - 0xFFFFFF
    /// Initialize color with red, green and blue values
    /// 
    /// - Parameter hex: hex value
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        self.init(hex: Int(int))
    }
}