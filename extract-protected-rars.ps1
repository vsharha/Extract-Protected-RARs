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
$passwords = Import-Csv -Path "rar_passwords.csv"

# Get all RAR files in the current directory
$rarFiles = Get-ChildItem -Filter "*.rar"

Write-Host "Starting extraction process - Logging failures to: $logFile"
Write-Log "Extraction process started by user: $env:USERNAME"
Write-Log "UTC Time: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss'))"

foreach ($rar in $rarFiles) {
    # Get RAR name without extension
    $rarName = [System.IO.Path]::GetFileNameWithoutExtension($rar.Name)
    
    # Find matching password in CSV
    $passwordEntry = $passwords | Where-Object { $_.rar_name -eq $rarName }
    
    if ($passwordEntry) {
        Write-Host "Processing: $($rar.Name)"
        
        # Create a folder for the RAR inside the extracted directory
        $folderPath = Join-Path $extractPath $rarName
        New-Item -ItemType Directory -Force -Path $folderPath | Out-Null
        
        # Extract the RAR using the password
        & "$7zipPath" x "`"$($rar.FullName)`"" "-o`"$folderPath`"" "-p$($passwordEntry.password)" -y
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully extracted: $($rar.Name)" -ForegroundColor Green
        } else {
            $errorMessage = "Failed to extract: $($rar.Name) - Exit code: $LASTEXITCODE"
            Write-Host $errorMessage -ForegroundColor Red
            Write-Log $errorMessage
        }
    } else {
        $errorMessage = "No password found for: $($rar.Name)"
        Write-Host "Warning: $errorMessage" -ForegroundColor Yellow
        Write-Log $errorMessage
    }
}

Write-Host "`nExtraction complete!" -ForegroundColor Cyan
Write-Host "All files have been extracted to the '$extractPath' folder"
Write-Host "Check $logFile for any failed extractions."
Write-Host "Original RAR files have been preserved."
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')