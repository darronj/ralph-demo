# Ralph Wiggum Loop Prompt

You are working on a feature using the Ralph Wiggum Loop.

## Your Task

1. **Read the PRD carefully** - Review all requirements and acceptance criteria
2. **Choose ONE incomplete requirement** - Pick any unchecked requirement (not necessarily the first one)
3. **Fully implement that requirement** - Write all necessary code, tests, and documentation
4. **Update the PRD file** - Check off the completed requirement (change `- [ ]` to `- [x]`)
5. **Append summary to ./progress.txt** - Write one line to the root-level progress.txt file with this format:

   ```text
   [YYYY-MM-DDTHH:MM:SS] Feature: <feature-path> - Completed: <brief requirement summary>
   ```

   - Use ISO 8601 timestamp format (e.g., `2026-01-13T14:30:00`)
   - If you encounter errors or get stuck, append:

     ```text
     [YYYY-MM-DDTHH:MM:SS] Feature: <feature-path> - ERROR: <brief error description>
     ```

## After Completing These Steps

Respond with exactly one of:
- `CONTINUE` - if more requirements remain unchecked
- `COMPLETE` - if ALL requirements and acceptance criteria are now checked off
- `ERROR: <specific error description>` - if you encountered an error during implementation
- `STUCK: <reason>` - if you cannot proceed for non-error reasons

## Critical Requirements

- **Actually implement** - Don't just plan or describe, write production-ready code
- **Update the PRD** - The requirement must be checked off in the file (only if successfully completed)
- **Write to progress.txt** - Root level (./progress.txt), not the feature's progress.md
  - ALWAYS append an entry on every iteration, whether success or error
  - Use `Completed:` for successful implementations
  - Use `ERROR:` for failures - be specific about what went wrong
- **Be thorough** - The requirement should be complete and tested
- **Check acceptance criteria** - Ensure your implementation meets both feature-specific and standard criteria
- **Report errors clearly** - If you hit an error, respond with `ERROR: <description>` and write the same error to progress.txt

## Notes

- You can choose which requirement to work on based on logical dependencies or complexity
- Each iteration should complete exactly ONE requirement fully
- The PRD file path and feature path will be provided in the context below
- **Auto-stop behavior**: If you report the same error twice in a row, the loop will automatically stop
  - This prevents infinite retry loops on the same issue
  - Always be specific in your error descriptions so duplicates are properly detected
  - If you encounter an error, try a different approach in the next iteration
