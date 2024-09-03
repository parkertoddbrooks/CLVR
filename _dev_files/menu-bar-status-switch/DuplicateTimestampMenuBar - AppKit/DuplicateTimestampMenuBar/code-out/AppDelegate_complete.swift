import Cocoa
import UserNotifications
import Security

// ... [Keep existing code above renameFile function] ...

func renameFile(at file: String) {
    let url = URL(fileURLWithPath: file)
    let dir = url.deletingLastPathComponent().path
    let fileExtension = url.pathExtension
    var name = url.deletingPathExtension().lastPathComponent
    
    let timestamp = formattedTimestamp()
    
    if name.lowercased().hasSuffix(" copy") {
        name = name.replacingOccurrences(of: " copy", with: "", options: [.caseInsensitive, .anchored])
        let newName = "\(name)-copy-\(timestamp).\(fileExtension)"
        moveFile(from: file, to: (dir as NSString).appendingPathComponent(newName))
    } else if let range = name.range(of: #"-copy-\d{4}-\d{2}-\d{2}-\d{6}(--\d{4}-\d{2}-\d{2}-\d{6})*$"#, options: .regularExpression) {
        let baseName = String(name[..<range.lowerBound])
        let newName = "\(baseName)-copy-\(timestamp).\(fileExtension)"
        moveFile(from: file, to: (dir as NSString).appendingPathComponent(newName))
    } else {
        log("File does not match renaming criteria: \(file)")
    }
}

// ... [Keep existing code below renameFile function] ...
