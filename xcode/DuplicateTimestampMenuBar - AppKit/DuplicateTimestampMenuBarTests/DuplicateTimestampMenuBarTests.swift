import XCTest
@testable import DuplicateTimestampMenuBar

class DuplicateTimestampMenuBarTests: XCTestCase {
    
    var appDelegate: AppDelegate!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        appDelegate = AppDelegate()
    }
    
    override func tearDownWithError() throws {
        appDelegate = nil
        try super.tearDownWithError()
    }
    
    func testFormattedTimestamp() {
        let timestamp = appDelegate.formattedTimestamp()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let expectedTimestamp = dateFormatter.string(from: Date())
        XCTAssertEqual(timestamp, expectedTimestamp, "Formatted timestamp should match expected format")
    }
    
    func testRenameFileCopy() {
        let testFile = "TestFile Copy.txt"
        let renamedFile = appDelegate.renameFile(at: testFile)
        XCTAssertTrue(renamedFile.contains("-copy-"), "Renamed file should contain '-copy-'")
        XCTAssertTrue(renamedFile.contains(".txt"), "Renamed file should maintain the original extension")
    }
    
    func testRenameFileExistingTimestamp() {
        let testFile = "TestFile-copy-2023-05-01-123456.txt"
        let renamedFile = appDelegate.renameFile(at: testFile)
        XCTAssertTrue(renamedFile.contains("-copy-"), "Renamed file should contain '-copy-'")
        XCTAssertNotEqual(renamedFile, testFile, "Renamed file should be different from the original")
    }
    
    func testRenameFileNoMatch() {
        let testFile = "TestFile.txt"
        let renamedFile = appDelegate.renameFile(at: testFile)
        XCTAssertEqual(renamedFile, testFile, "File not matching criteria should not be renamed")
    }
    
    func testVerifyFolderAccess() {
        // This test assumes that the Desktop and Documents folders are accessible
        XCTAssertTrue(appDelegate.verifyFolderAccess(), "Folder access should be verified")
    }
    
    func testGetWatchedPaths() {
        let paths = appDelegate.getWatchedPaths()
        XCTAssertEqual(paths.count, 2, "There should be two watched paths")
        XCTAssertTrue(paths.contains { $0.hasSuffix("/Desktop") }, "Desktop should be in watched paths")
        XCTAssertTrue(paths.contains { $0.hasSuffix("/Documents") }, "Documents should be in watched paths")
    }
}
