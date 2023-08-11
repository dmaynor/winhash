# Set error action preference to silently continue on errors
$ErrorActionPreference = 'SilentlyContinue'

# Define the output file name format
$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$outputFile = "hashrun-$timestamp.csv"
$maxFileLog = "hashrun-$timestamp_maxfile.log"

# Function to compute hash values for a file and write to CSV
function ComputeHashForFile($file, $currentIndex, $totalCount) {
    try {
        # Getting file hashes
        $md5 = (Get-FileHash -Path $file.FullName -Algorithm MD5).Hash
        $sha1 = (Get-FileHash -Path $file.FullName -Algorithm SHA1).Hash
        $sha256 = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash

        # Constructing the result object
        $result = [PSCustomObject]@{
            'FileName'      = $file.Name
            'FullPath'      = $file.FullName
            'MD5'           = $md5
            'SHA1'          = $sha1
            'SHA256'        = $sha256
            'CreationDate'  = $file.CreationTime
            'AccessDate'    = $file.LastAccessTime
            'ModifiedDate'  = $file.LastWriteTime
        }

        # Append the result to CSV file
        $result | Export-Csv -Path $outputFile -NoTypeInformation -Append

        # Update progress bar
        $percentComplete = ($currentIndex / $totalCount) * 100
        Write-Progress -PercentComplete $percentComplete -Status "Processing Files" -Activity "$currentIndex of $totalCount files processed."

    } catch {
        Write-Error "Failed to process file: $($file.FullName). Error: $($_.Exception.Message)"
    }
}

# Create CSV header by exporting an empty object (this will ensure headers are written)
[PSCustomObject]@{
    'FileName'      = $null
    'FullPath'      = $null
    'MD5'           = $null
    'SHA1'          = $null
    'SHA256'        = $null
    'CreationDate'  = $null
    'AccessDate'    = $null
    'ModifiedDate'  = $null
} | Export-Csv -Path $outputFile -NoTypeInformation

# Use Get-ChildItem to get all files and handle access denied errors
$files = Get-ChildItem -Path "C:\" -Recurse -File

# Write the total file count to the log file
$totalCount = $files.Count
$totalCount | Out-File $maxFileLog

# Process the files with progress bar
$currentIndex = 0
$files | ForEach-Object {
    $currentIndex++
    ComputeHashForFile $_ $currentIndex $totalCount
}

Write-Output "Hash computation completed. Results saved to $outputFile"
