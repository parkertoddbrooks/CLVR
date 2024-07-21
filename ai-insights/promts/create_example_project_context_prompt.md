To create an example project context prompt based on your existing work, please follow these steps:

1. Analyze the contents of your /ai-insights/ directory.

2. Create a new file named 'example_project_context_prompt.md' in the /ai-insights/promts/ directory.

3. Start the file with a brief introduction:
   "We are working on a project located at: [PROJECT_ROOT_DIRECTORY]"

4. List the key files to be read and analyzed, typically including:
   - README.md
   - Main script or code files
   - Configuration files

5. If there are development summaries in /ai-insights/dev-summaries/, add:
   "After reading these files, please review the latest development summary located at:
   [PROJECT_ROOT_DIRECTORY]/ai-insights/dev-summaries/[LATEST_SUMMARY_FILE]"

6. Include requests for:
   - A brief summary of the project's purpose and main features
   - Current implementation details
   - Recent changes or updates
   - Potential areas for future improvement

7. Add instructions to ignore token-intensive directories:
   "When analyzing the project, please ignore any folders named '_git-ignore' or '/cli-dump/' as these may contain large amounts of data not directly relevant to the current project state."

8. If applicable, add references to other relevant directories within /ai-insights/, such as:
   - error-logs
   - PRDs
   - Any project-specific directories

9. Conclude with:
   "After analyzing these files, you should be prepared to assist with any questions or tasks related to this project, including code modifications, documentation updates, or troubleshooting."

10. Review the created example_project_context_prompt.md and adjust as necessary to accurately reflect your project's structure and needs.

This prompt will help you create a tailored project context prompt that leverages your existing work and project structure.