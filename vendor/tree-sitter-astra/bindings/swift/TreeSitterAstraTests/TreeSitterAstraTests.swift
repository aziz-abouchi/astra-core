import XCTest
import SwiftTreeSitter
import TreeSitterAstra

final class TreeSitterAstraTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_astra())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Astra HM gramar grammar")
    }
}
