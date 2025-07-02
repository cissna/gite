#!/bin/bash
#
# test_interactive_commit.sh
#
# A test script to demonstrate capturing logs from an interactive
# command (`git commit`) using the `script` utility.

# --- Setup ---
# Ensure we are in a git repository.
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: This script must be run from within a Git repository."
    exit 1
fi

# Ensure there's something to commit.
# if git diff-index --quiet HEAD --; then
#     echo "No changes to commit. Please stage some changes first (e.g., 'git add .')."
#     exit 1
# fi

# Create a temporary file to hold the session log.
LOG_FILE=$(mktemp)
# echo "Temporary log file created at: $LOG_FILE"
# echo "--------------------------------------------------"
# echo

# --- Execution ---
# echo "Running 'git commit' interactively..."
# echo "Your default editor will open. Please enter a commit message."
# echo

# Use `script` to execute the command.
# The syntax `script [options] [file] [command]` is used for BSD/macOS compatibility.
# The `-q` flag runs in quiet mode.
script -q "$LOG_FILE" git add -p
exit_code=$?

# --- Log Display and Analysis ---
# echo
# echo "--------------------------------------------------"
# echo "Interactive session finished."
# echo "Displaying the full captured log from '$LOG_FILE':"
echo
echo
echo
echo
echo "--- LOG START ---"
# Check if the log file has content before trying to display it
if [ -s "$LOG_FILE" ]; then
    cat "$LOG_FILE"
# else
#     echo "[No output was captured in the log]"
fi
echo "--- LOG END ---"
echo

# --- Result ---
# if [ $exit_code -eq 0 ]; then
#     echo -e "\033[0;32mSuccess:\033[0m 'git commit' completed successfully."
# else
#     echo -e "\033[0;31mFailure:\033[0m 'git commit' failed or was cancelled. Exit code: $exit_code"
# fi
# echo

# --- Cleanup ---
rm "$LOG_FILE"
# echo "Temporary log file removed."


