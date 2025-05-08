# PowerShell script to convert all image file paths to lowercase
Write-Host "Starting image file case conversion..."

# Function to convert a directory's files and subdirectories to lowercase
function Convert-DirectoryFilesToLowercase {
    param (
        [string]$directory
    )
    
    # Process files in the current directory
    $files = Get-ChildItem -Path $directory -File
    foreach ($file in $files) {
        $lowercaseName = $file.Name.ToLower()
        if ($file.Name -ne $lowercaseName) {
            $newPath = Join-Path -Path $file.DirectoryName -ChildPath $lowercaseName
            Write-Host "Renaming $($file.FullName) to $newPath"
            Rename-Item -Path $file.FullName -NewName $lowercaseName -Force
        }
    }
    
    # Process subdirectories (excluding special directories)
    $subdirectories = Get-ChildItem -Path $directory -Directory | Where-Object { 
        $_.Name -ne "node_modules" -and $_.Name -ne ".git" -and $_.Name -ne ".next" 
    }
    
    foreach ($subdir in $subdirectories) {
        # Convert directory name to lowercase if needed
        $lowercaseDirName = $subdir.Name.ToLower()
        if ($subdir.Name -ne $lowercaseDirName) {
            $tempName = "temp_" + (Get-Random)
            $tempPath = Join-Path -Path $subdir.Parent.FullName -ChildPath $tempName
            
            # Rename to temp name first to avoid case-insensitive conflicts
            Rename-Item -Path $subdir.FullName -NewName $tempName -Force
            
            # Then rename to lowercase
            $newDirPath = Join-Path -Path $subdir.Parent.FullName -ChildPath $lowercaseDirName
            Rename-Item -Path $tempPath -NewName $lowercaseDirName -Force
            
            Write-Host "Renamed directory $($subdir.FullName) to $newDirPath"
            
            # Continue with the lowercase directory
            Convert-DirectoryFilesToLowercase -directory $newDirPath
        } else {
            # Process the subdirectory recursively
            Convert-DirectoryFilesToLowercase -directory $subdir.FullName
        }
    }
}

# Start with the docs/images directory
$imageDir = "docs/images"
if (Test-Path $imageDir) {
    Write-Host "Processing images in $imageDir..."
    Convert-DirectoryFilesToLowercase -directory $imageDir
} else {
    Write-Host "Directory $imageDir not found."
}

Write-Host "Image case conversion complete." 