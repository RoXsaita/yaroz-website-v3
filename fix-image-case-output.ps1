# PowerShell script to ensure all image files in the output directory are lowercase
Write-Host "Starting image file case conversion for output directory..."

# Function to convert filenames to lowercase
function Convert-FilesToLowercase {
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
            
            try {
                # Use temporary name to avoid case sensitivity issues on Windows
                $tempName = "temp_" + [Guid]::NewGuid().ToString() + $file.Extension
                $tempPath = Join-Path -Path $file.DirectoryName -ChildPath $tempName
                
                # Two-step rename
                Rename-Item -Path $file.FullName -NewName $tempName -Force
                Rename-Item -Path $tempPath -NewName $lowercaseName -Force
            }
            catch {
                Write-Host "Error renaming file: $_" -ForegroundColor Red
            }
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
            try {
                $tempName = "temp_" + [Guid]::NewGuid().ToString()
                $tempPath = Join-Path -Path $subdir.Parent.FullName -ChildPath $tempName
                
                # Rename to temp name first to avoid case-insensitive conflicts
                Rename-Item -Path $subdir.FullName -NewName $tempName -Force
                
                # Then rename to lowercase
                $newDirPath = Join-Path -Path $subdir.Parent.FullName -ChildPath $lowercaseDirName
                Rename-Item -Path $tempPath -NewName $lowercaseDirName -Force
                
                Write-Host "Renamed directory $($subdir.FullName) to $newDirPath"
                
                # Continue with the lowercase directory
                Convert-FilesToLowercase -directory $newDirPath
            }
            catch {
                Write-Host "Error renaming directory: $_" -ForegroundColor Red
            }
        } else {
            # Process the subdirectory recursively
            Convert-FilesToLowercase -directory $subdir.FullName
        }
    }
}

# Process the out/images directory
$outImageDir = "out/images"
if (Test-Path $outImageDir) {
    Write-Host "Processing images in $outImageDir..."
    Convert-FilesToLowercase -directory $outImageDir
} else {
    Write-Host "Directory $outImageDir not found." -ForegroundColor Yellow
}

# Process the docs/images directory too
$docsImageDir = "docs/images"
if (Test-Path $docsImageDir) {
    Write-Host "Processing images in $docsImageDir..."
    Convert-FilesToLowercase -directory $docsImageDir
} else {
    Write-Host "Directory $docsImageDir not found." -ForegroundColor Yellow
}

Write-Host "Image case conversion complete." 