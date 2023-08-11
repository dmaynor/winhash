# Define the output file name format
$timestamp = Get-Date -Format "yyyy-MM-dd-HH-mm-ss"
$outputFile = "hashrun-$timestamp.csv"

# Count the total number of files to be processed and provide feedback
$counter = 0
$totalFiles = (Get-ChildItem -Path C:\ -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    $counter++
    Write-Progress -Status "Counting Files" -Activity "Discovered $counter files so far..." -PercentComplete ($counter % 100) 
    $_
}).Count

$processedFiles = 0
$startTime = Get-Date

# Function to compute hash values for a file and write to CSV
function ComputeHashForFile($file) {
    global $processedFiles, $startTime, $totalFiles

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

        # Update progress
        $remainingFiles = $totalFiles - $processedFiles
        $processedFiles++
        $elapsedTime = [datetime]::Now - $startTime
        $estimatedTotalTime = $elapsedTime * ($totalFiles / $processedFiles)
        $timeRemaining = $estimatedTotalTime - $elapsedTime

        Write-Progress -PercentComplete ((($totalFiles - $remainingFiles) / $totalFiles) * 100) -Status "Processing Files" -Activity "$remainingFiles files remaining. Estimated time remaining: $($timeRemaining.ToString("hh\:mm\:ss"))"

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

# Recursively find all files starting from C:\ and compute their hash values
Get-ChildItem -Path C:\ -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    ComputeHashForFile $_
}

Write-Output "Hash computation completed. Results saved to $outputFile"
