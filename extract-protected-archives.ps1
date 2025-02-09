# Set the path to 7-Zip (modify this according to your 7-Zip installation path)
$7zipPath = "C:\Program Files\7-Zip\7z.exe"

# Set log file name with timestamp using UTC
$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd_HH-mm-ss")
$logFile = "failed_extractions_$timestamp.log"

# Function to write to log file
function Write-Log {
    param($Message)
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

# Create main extraction directory
$extractPath = "extracted"
New-Item -ItemType Directory -Force -Path $extractPath | Out-Null

# Import the CSV file (should be in the same directory as the script)
$passwords = Import-Csv -Path "passwords.csv"

# Get all supported archive files in the current directory
$archiveFiles = Get-ChildItem -Filter "*.*" | Where-Object { 
    $_.Extension -match '\.(7z|rar|zip|tar|gz|bz2|xz)$'
}

Write-Host "Starting extraction process - Logging failures to: $logFile"
Write-Log "Extraction process started by user: $env:USERNAME"
Write-Log "UTC Time: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss'))"

foreach ($archive in $archiveFiles) {
    # Get archive name without extension
    $archiveName = [System.IO.Path]::GetFileNameWithoutExtension($archive.Name)
    
    # Find matching password in CSV
    $passwordEntry = $passwords | Where-Object { $_.archive_name -eq $archiveName }
    
    if ($passwordEntry) {
        Write-Host "Processing: $($archive.Name)"
        
        # Create a folder for the archive inside the extracted directory
        $folderPath = Join-Path $extractPath $archiveName
        New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
        
        # Extract the archive using the password
        & "$7zipPath" x "`"$($archive.FullName)`"" "-o`"$folderPath`"" "-p$($passwordEntry.password)" -y
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully extracted: $($archive.Name)" -ForegroundColor Green
        } else {
            $errorMessage = "Failed to extract: $($archive.Name) - Exit code: $LASTEXITCODE"
            Write-Host $errorMessage -ForegroundColor Red
            Write-Log $errorMessage
        }
    } else {
        $errorMessage = "No password found for: $($archive.Name)"
        Write-Host "Warning: $errorMessage" -ForegroundColor Yellow
        Write-Log $errorMessage
    }
}

Write-Host "`nExtraction complete!" -ForegroundColor Cyan
Write-Host "All files have been extracted to the '$extractPath' folder"
Write-Host "Check $logFile for any failed extractions."
Write-Host "Original archive files have been preserved."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')