This script is available as a Windows Batch file as well as a Powershell script.

Pre-requisites:

-   7-zip

To use it, put the script in the same directory as your protected .RAR files as well as a CSV file called `rar_passwords.csv`. Your CSV should have the following structure:

```csv
rar_name,password
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
   │   └─ (contents of Documents 2023.rar)
   └─ 📁 Backup Files/
       └─ (contents of Backup Files.rar)
```
