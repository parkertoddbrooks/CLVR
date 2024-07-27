import Foundation

class ScriptManager {
    static let shared = ScriptManager()
    
    private init() {}
    
    func startDuplicateTimestamp() -> Bool {
        return runScript("DuplicateFileManager.sh", arguments: ["start"])
    }
    
    func stopDuplicateTimestamp() -> Bool {
        return runScript("DuplicateFileManager.sh", arguments: ["stop"])
    }
    
    private func runScript(_ name: String, arguments: [String]) -> Bool {
        guard let scriptPath = Bundle.main.path(forResource: name, ofType: "sh") else {
            print("Failed to locate script: \(name)")
            return false
        }
        
        let fileManager = FileManager.default
        
        // Ensure the script is executable
        try? fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [scriptPath] + arguments
        
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            print("Failed to run script: \(error.localizedDescription)")
            return false
        }
    }
}