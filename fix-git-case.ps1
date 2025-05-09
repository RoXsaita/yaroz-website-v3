# PowerShell script to fix case sensitivity issues in Git
Write-Host "Starting Git case sensitivity fix..."

# Function to rename files to lowercase using a two-step process to force Git to recognize the change
function Fix-GitCaseSensitivity {
    param (
        [string]$directory
    )
    
    # Get all image files in the directory and subdirectories
    $files = Get-ChildItem -Path $directory -Recurse -Include "*.jpg","*.png","*.svg","*.mp4","*.webp","*.gif"
    
    foreach ($file in $files) {
        $lowercaseName = $file.Name.ToLower()
        
        # Only process files that have uppercase letters
        if ($file.Name -cne $lowercaseName) {
            Write-Host "Processing: $($file.FullName)"
            
            # Step 1: Rename to a temporary name
            $tempName = [Guid]::NewGuid().ToString() + $file.Extension
            $tempPath = Join-Path -Path $file.DirectoryName -ChildPath $tempName
            
            Write-Host "  Renaming to temp: $tempName"
            git mv $file.FullName $tempPath
            
            # Step 2: Rename to the lowercase name
            $lowercasePath = Join-Path -Path $file.DirectoryName -ChildPath $lowercaseName
            
            Write-Host "  Renaming to lowercase: $lowercaseName"
            git mv $tempPath $lowercasePath
            
            Write-Host "  Done!"
        }
    }
    
    # Process directories too (to handle uppercase directory names)
    $dirs = Get-ChildItem -Path $directory -Directory
    foreach ($dir in $dirs) {
        # Don't recurse into special directories
        if ($dir.Name -ne "node_modules" -and $dir.Name -ne ".git" -and $dir.Name -ne ".next") {
            $lowercaseDirName = $dir.Name.ToLower()
            
            # Only process directories that have uppercase letters
            if ($dir.Name -cne $lowercaseDirName) {
                Write-Host "Processing directory: $($dir.FullName)"
                
                # Rename directory to lowercase using git mv
                $parentDir = $dir.Parent.FullName
                $tempDirName = [Guid]::NewGuid().ToString()
                $tempDirPath = Join-Path -Path $parentDir -ChildPath $tempDirName
                
                Write-Host "  Renaming directory to temp: $tempDirName"
                git mv $dir.FullName $tempDirPath
                
                $lowercaseDirPath = Join-Path -Path $parentDir -ChildPath $lowercaseDirName
                Write-Host "  Renaming directory to lowercase: $lowercaseDirName"
                git mv $tempDirPath $lowercaseDirPath
                
                Write-Host "  Done!"
            } else {
                # Recursively process subdirectories
                Fix-GitCaseSensitivity -directory $dir.FullName
            }
        }
    }
}

# Process the images directory
$imageDir = "public/images"
if (Test-Path $imageDir) {
    Write-Host "Found images directory: $imageDir"
    Fix-GitCaseSensitivity -directory $imageDir
} else {
    Write-Host "ERROR: Images directory not found at $imageDir" -ForegroundColor Red
}

# Also check the docs/images directory
$docsImageDir = "docs/images"
if (Test-Path $docsImageDir) {
    Write-Host "Found docs images directory: $docsImageDir"
    Fix-GitCaseSensitivity -directory $docsImageDir
} else {
    Write-Host "ERROR: Docs images directory not found at $docsImageDir" -ForegroundColor Red
}

Write-Host "Case sensitivity fix complete." 