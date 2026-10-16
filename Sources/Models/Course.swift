import Foundation
import SwiftUI

public struct Course: Identifiable, Codable, Equatable {
    public let id: Int
    public let fullname: String
    public let shortname: String
    public let summary: String
    public var themeColorHex: String
    public var teacherName: String
    public var teacherEmail: String
    public var assignmentsDueSoon: [Assignment]
    public var progress: Double?

    public init(
        id: Int,
        fullname: String,
        shortname: String,
        summary: String = "",
        themeColorHex: String = "#1A73E8",
        teacherName: String = "Profesorado Digitech FP",
        teacherEmail: String = "campus@digitechfp.com",
        assignmentsDueSoon: [Assignment] = [],
        progress: Double? = nil
    ) {
        self.id = id
        self.fullname = fullname
        self.shortname = shortname
        self.summary = summary
        self.themeColorHex = themeColorHex
        self.teacherName = teacherName
        self.teacherEmail = teacherEmail
        self.assignmentsDueSoon = assignmentsDueSoon
        self.progress = progress
    }

    public var bannerColor: Color {
        Color(hex: themeColorHex)
    }
}

// Color hex helper
extension Color {
    public init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 26, 115, 232) // Default Google Blue #1A73E8
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
