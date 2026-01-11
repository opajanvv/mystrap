# Cleanup Downloads

Remove files from ~/Downloads that haven't been accessed in over a week, then remove any empty directories.

## Instructions

1. Find all files in ~/Downloads that have an access time (atime) older than 7 days
2. List these files with their sizes and show the user what will be deleted before proceeding
3. Calculate and display the total disk space that will be freed
4. Ask for confirmation before deleting
5. Delete the confirmed files
6. After file deletion, find and remove any empty directories within ~/Downloads
7. Report what was deleted and the total disk space freed

Use `find` with `-atime +7` to identify files not accessed in over 7 days.
