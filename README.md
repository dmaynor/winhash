## PowerShell File Hashing Script

### Overview:
This script computes the MD5, SHA1, and SHA256 hashes for every file starting from the root directory (`C:\`) and writes the results to a CSV file. The CSV file will contain the following columns:

- `FileName`: The name of the file.
- `FullPath`: The complete path to the file.
- `MD5`: The MD5 hash of the file.
- `SHA1`: The SHA1 hash of the file.
- `SHA256`: The SHA256 hash of the file.
- `CreationDate`: The date and time when the file was created.
- `AccessDate`: The last date and time when the file was accessed.
- `ModifiedDate`: The last date and time when the file was modified.

The name of the CSV output file is in the format `hashrun-YEAR-MONTH-DAY-Hour-Minute-Second.csv`, based on the current timestamp when the script is run.

### Usage:
1. Save the script to a `.ps1` file.
2. Run PowerShell as an administrator.
3. Navigate to the directory containing the `.ps1` file.
4. Execute the script by typing `.\YourScriptName.ps1`.

### Features:
- **Recursive Search**: The script will search for files in all directories and subdirectories starting from `C:\`.
- **Immediate Write to Disk**: After hashing each file, the result is immediately written to the CSV file. This ensures data is saved continuously even if the script encounters issues during its execution.
- **Error Handling**: The script has built-in error handling. If there's an issue processing a file (e.g., due to permissions), the error will be printed to the console, and the script will continue processing the next file.

### Note:
Always ensure you understand the actions of any script and have appropriate permissions before executing it.

