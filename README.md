# Extract Protected Archives

## Purpose

This allows for mass extracting password-protected archives. I decided to automate this because I found doing this by hand annoying.

## Usage instructions

This script is available as a Windows Batch file as well as a Powershell script.

Pre-requisites:

-   7-zip

To use it, put the script in the same directory as your protected archive files as well as a CSV file called `passwords.csv`. Your CSV should have the following structure:

```csv
archive_name,password
My Game,password123
Documents 2025,pass456
Backup Files,mypass789
```

The script will unpack your RARs into the following structure:

```
📁 extracted/
   ├─ 📁 My Game/
   │   └─ (contents of My Game.rar)
   ├─ 📁 Documents 2025/
   │   └─ (contents of Documents 2023.7z)
   └─ 📁 Backup Files/
       └─ (contents of Backup Files.tar)
```
