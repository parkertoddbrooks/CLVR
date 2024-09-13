# Security Brief: CLVR File Renaming Application

## 1. Overview

CLVR is a macOS application designed to automatically rename files in the user's Desktop and Documents folders. The app employs a security-focused approach to file system access and monitoring, prioritizing user privacy and system integrity.

## 2. File Access Methodology

### a. Security-Scoped Bookmarks
- Instead of requesting broad, system-wide access, CLVR uses security-scoped bookmarks.
- These bookmarks provide persistent, user-approved access to specific folders.
- This method limits the app's access to only the folders explicitly selected by the user.

### b. File System Events (FSEvents)
- CLVR utilizes the FSEvents API for file system monitoring.
- This API allows for efficient change detection without requiring elevated system permissions.

## 3. Permission Model

### a. User-Driven Permission Granting
- The app prompts users to select the Desktop and Documents folders explicitly.
- This approach ensures users are fully aware of which folders the app can access.
- Permissions are granted on a per-folder basis, enhancing granularity of access control.

### b. Absence from System-Wide Settings
- CLVR intentionally does not appear in System Settings > Privacy & Security > Files and Folders.
- This is a result of using security-scoped bookmarks rather than broad file system access requests.
- It reflects a more fine-grained, app-specific permission model.

## 4. Security Benefits

### a. Principle of Least Privilege
- The app requests and receives access only to the specific folders it needs to function.
- This minimizes the potential impact of any security vulnerabilities.

### b. User Control
- Users have direct control over which folders the app can access.
- Permissions can be easily revoked by the user by deleting the app or its preferences.

### c. Reduced Attack Surface
- By not requesting system-wide permissions, the app reduces its potential as a target for exploitation.

### d. Transparency
- The permission request process is clear and user-initiated, enhancing trust and transparency.

## 5. Privacy Considerations
- The app only accesses and modifies files in user-selected folders.
- No data is transmitted outside of the user's system.
- File monitoring is limited to detecting changes for renaming purposes only.

## 6. Rationale for Implementation
- **Security**: This approach provides a strong security posture by limiting the app's access and capabilities.
- **User Trust**: Clear, user-controlled permission granting builds trust in the application.
- **Functionality**: The chosen methods allow the app to perform its core functions efficiently without overreaching in its access.
- **Compliance**: This implementation aligns well with Apple's guidelines for responsible file system access.

## 7. Potential Trade-offs
- Users familiar with system-wide permission settings might initially be confused by the app's absence in these settings.
- The app requires a custom onboarding process to explain its permission model to users.

## Conclusion
CLVR's security model prioritizes user control, minimal access, and transparency. By using security-scoped bookmarks and FSEvents, the app achieves its functionality while maintaining a strong security posture. This approach may differ from some users' expectations but ultimately provides a more secure and privacy-respecting implementation for file system interactions.