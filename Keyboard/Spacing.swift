import Foundation

// Pure rules, independent of UIKit; tested by Tests/main.swift.
enum Spacing {
    static func insertion(_ key: String, before: String) -> String {
        if key == " " { return "   " }
        guard let character = key.first, key.count == 1,
              character.isLetter || character.isNumber,
              let previous = before.last,
              previous.isLetter || previous.isNumber else { return key }
        return " " + key
    }

    static func deleteCount(before: String) -> Int {
        guard let last = before.last else { return 1 }
        // A word separator is three spaces. A second press removes a letter.
        if before.hasSuffix("   ") { return 3 }
        // Delete the letter and its single inter-letter space together.
        let chars = Array(before.suffix(3))
        if (last.isLetter || last.isNumber), chars.count == 3,
           chars[1] == " ", (chars[0].isLetter || chars[0].isNumber) {
            return 2
        }
        return 1
    }
}
