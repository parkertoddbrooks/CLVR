# Prompt Engineering Examples

This document provides examples of effective prompts used during the AI-assisted development process of the "Duplicate File and Update Name with Timestamp" project. These examples demonstrate best practices in prompt engineering and can serve as a guide for others working with AI assistants and LLMs in software development.

## 1. Context-Setting Prompt

Example:
```
We are working on a project called "Duplicate File and Update Name with Timestamp" located at:
/Users/parker/Documents/dev/claude-engineer/_Projects/duplicate-file-and-update-name-with-timestamp-sh

The project is currently experiencing an issue with loading the launch agent. When attempting to load the plist file, we encounter the following error:

"Load failed: 5: Input/output error"

Please read and analyze the following files in order:

1. README.md
2. rename_duplicate.sh
3. com.user.fswatchrename.plist

After reading these files, please provide:
1. A brief summary of the project's purpose and main features.
2. The current implementation details, including the script's functionality and how it's set up to run automatically.
3. An analysis of the potential causes for the "Input/output error" when loading the launch agent.
4. Suggestions for troubleshooting steps or potential solutions to resolve the launchd loading issue.
```

Why it's effective:
- Provides clear project context and location
- Specifies the current issue and error message
- Lists specific files to analyze in a particular order
- Requests clear, structured outputs

## 2. Iterative Development Prompt

Example:
```
Based on your previous analysis of the "Duplicate File and Update Name with Timestamp" project, we've implemented the following changes:

1. Modified the plist file to use absolute paths
2. Updated the shell script to include error logging
3. Added a check for necessary permissions in the launch script

However, we're still encountering issues with the launch agent. Please review the updated files:

1. com.user.fswatchrename.plist
2. rename_duplicate.sh
3. launch_check.sh

Considering these changes, please provide:
1. An analysis of how these modifications address the previous issues
2. Any potential new issues that might have been introduced
3. Suggestions for further improvements or alternative approaches
4. A step-by-step plan for testing these changes to ensure they resolve the original problem
```

Why it's effective:
- Acknowledges previous AI input and shows how it was applied
- Clearly states the changes made
- Asks for analysis of new changes and their impact
- Requests forward-looking suggestions and a testing plan

## 3. Error Analysis Prompt

Example:
```
We've encountered a new error in the "Duplicate File and Update Name with Timestamp" project. The error occurs when trying to rename a file:

Error message: "rename: Invalid argument"

This error is logged in the file:
/Users/parker/Library/Logs/rename_duplicate.log

Please analyze this error log and the relevant parts of the script:

1. rename_duplicate.sh (lines 50-75)
2. file_operations.sh (entire file)

Based on this information, please provide:
1. A detailed explanation of what might be causing this "Invalid argument" error
2. Potential scenarios where this error could occur
3. Suggestions for modifying the script to handle this error gracefully
4. Any additional logging or debugging steps we should implement to gather more information about this issue
```

Why it's effective:
- Provides a specific error message and its context
- Points to relevant log files and specific parts of the code
- Asks for a detailed explanation and analysis
- Requests both solutions and further debugging strategies

These examples demonstrate how to craft prompts that provide clear context, specify the information to be analyzed, and request structured, actionable outputs. By following these patterns, developers can more effectively leverage AI assistants in their software development processes.