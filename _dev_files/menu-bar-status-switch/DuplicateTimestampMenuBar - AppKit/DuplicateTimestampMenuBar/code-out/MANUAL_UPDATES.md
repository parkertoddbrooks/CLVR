# Manual Updates for AppDelegate.swift

Please make the following changes to the AppDelegate.swift file:

1. Update the `renameFile(at:)` function:
   - Change the function signature to make it public and return a String:
     ```swift
     public func renameFile(at file: String) -> String {
     ```
   - At the end of the function, return the new file path:
     ```swift
     return newPath
     ```

2. Update the `formattedTimestamp()` function:
   - Change the function signature to make it public:
     ```swift
     public func formattedTimestamp() -> String {
     ```

3. Replace the entire `getWatchedPaths()` function with:
   ```swift
   public func getWatchedPaths() -> [String] {
       return resolveBookmarks().map { $0.path }
   }
   ```

4. Replace the entire `verifyFolderAccess()` function with:
   ```swift
   public func verifyFolderAccess() -> Bool {
       let urls = resolveBookmarks()
       for url in urls {
           guard url.startAccessingSecurityScopedResource() else {
               return false
           }
           defer { url.stopAccessingSecurityScopedResource() }
           
           if !FileManager.default.isReadableFile(atPath: url.path) || !FileManager.default.isWritableFile(atPath: url.path) {
               return false
           }
       }
       return true
   }
   ```

5. Ensure that the `createAndStoreBookmarks()` and `resolveBookmarks()` functions are present and correct:
   ```swift
   private func createAndStoreBookmarks() {
       let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
       let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       
       do {
           desktopBookmark = try desktopURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
           documentsBookmark = try documentsURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
           
           UserDefaults.standard.set(desktopBookmark, forKey: "DesktopBookmark")
           UserDefaults.standard.set(documentsBookmark, forKey: "DocumentsBookmark")
           
           log("Bookmarks created and stored successfully")
       } catch {
           log("Error creating bookmarks: \(error.localizedDescription)")
       }
   }

   private func resolveBookmarks() -> [URL] {
       var urls: [URL] = []
       
       if let desktopBookmark = UserDefaults.standard.data(forKey: "DesktopBookmark"),
          let documentsBookmark = UserDefaults.standard.data(forKey: "DocumentsBookmark") {
           do {
               var isStale = false
               let desktopURL = try URL(resolvingBookmarkData: desktopBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
               urls.append(desktopURL)
               
               isStale = false
               let documentsURL = try URL(resolvingBookmarkData: documentsBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
               urls.append(documentsURL)
               
               log("Bookmarks resolved successfully")
           } catch {
               log("Error resolving bookmarks: \(error.localizedDescription)")
           }
       }
       
       return urls
   }
   ```

6. Update the `requestPermission()` function to use `createAndStoreBookmarks()`:
   ```swift
   func requestPermission() {
       let openPanel = NSOpenPanel()
       openPanel.canChooseDirectories = true
       openPanel.canChooseFiles = false
       openPanel.allowsMultipleSelection = false
       openPanel.message = "Please select your Desktop folder"
       openPanel.prompt = "Select Desktop"
       
       if openPanel.runModal() == .OK {
           guard let desktopURL = openPanel.url else {
               log("Failed to get Desktop URL")
               return
           }
           
           openPanel.message = "Please select your Documents folder"
           openPanel.prompt = "Select Documents"
           
           if openPanel.runModal() == .OK {
               guard let documentsURL = openPanel.url else {
                   log("Failed to get Documents URL")
                   return
               }
               
               createAndStoreBookmarks()
               
               if verifyFolderAccess() {
                   startWatching()
               } else {
                   log("Failed to gain access to watched folders")
                   let failureAlert = NSAlert()
                   failureAlert.messageText = "Access Denied"
                   failureAlert.informativeText = "Failed to gain access to the Desktop and Documents folders. Please check your system preferences and try again."
                   failureAlert.alertStyle = .critical
                   failureAlert.runModal()
               }
           }
       }
   }
   ```

After making these changes, the AppDelegate.swift file should be properly set up to use security-scoped bookmarks and have the necessary public functions for testing.