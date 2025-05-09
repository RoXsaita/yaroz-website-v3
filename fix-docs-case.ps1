# PowerShell script to fix case sensitivity issues in the docs directory
# This is important for GitHub Pages which is case-sensitive

Write-Host "Starting case sensitivity fix for docs directory..." -ForegroundColor Cyan

function Fix-CaseSensitivity {
    param (
        [string]$directory
    )
    
    Write-Host "`nProcessing directory: $directory" -ForegroundColor Cyan
    
    # Check if the directory exists
    if (-not (Test-Path $directory)) {
        Write-Host "Directory not found: $directory" -ForegroundColor Red
        return
    }
    
    # Process image files
    $imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.svg", "*.mp4")
    $files = Get-ChildItem -Path $directory -Recurse -Include $imageExtensions
    
    Write-Host "Found $($files.Count) image files to process"
    
    $renamedFiles = 0
    
    # First pass: Process files that need renaming
    foreach ($file in $files) {
        $directory = $file.DirectoryName
        $lowercaseName = $file.Name.ToLower()
        
        # Only process if the name is not already lowercase
        if ($file.Name -cne $lowercaseName) {
            $tempName = [System.IO.Path]::Combine($directory, "temp_$([Guid]::NewGuid().ToString())")
            $newName = [System.IO.Path]::Combine($directory, $lowercaseName)
            
            Write-Host "  • Renaming: $($file.Name) -> $lowercaseName" -ForegroundColor Yellow
            
            # Use a two-step rename to handle case-only changes on Windows
            try {
                Rename-Item -Path $file.FullName -NewName $tempName -Force
                Rename-Item -Path $tempName -NewName $newName -Force
                $renamedFiles++
            }
            catch {
                Write-Host "    ERROR: Failed to rename $($file.FullName): $_" -ForegroundColor Red
            }
        }
    }
    
    # Process directories (bottom-up to avoid path issues)
    $directories = Get-ChildItem -Path $directory -Directory -Recurse | Sort-Object -Property FullName -Descending
    $renamedDirs = 0
    
    foreach ($dir in $directories) {
        $parentDir = $dir.Parent.FullName
        $lowercaseName = $dir.Name.ToLower()
        
        # Only process if the name is not already lowercase
        if ($dir.Name -cne $lowercaseName) {
            $tempName = [System.IO.Path]::Combine($parentDir, "temp_$([Guid]::NewGuid().ToString())")
            $newName = [System.IO.Path]::Combine($parentDir, $lowercaseName)
            
            Write-Host "  • Renaming directory: $($dir.Name) -> $lowercaseName" -ForegroundColor Yellow
            
            # Use a two-step rename to handle case-only changes on Windows
            try {
                Rename-Item -Path $dir.FullName -NewName $tempName -Force
                Rename-Item -Path $tempName -NewName $newName -Force
                $renamedDirs++
            }
            catch {
                Write-Host "    ERROR: Failed to rename directory $($dir.FullName): $_" -ForegroundColor Red
            }
        }
    }
    
    # Summary
    Write-Host "`nSummary for $($directory):" -ForegroundColor Cyan
    Write-Host "  • Files renamed to lowercase: $renamedFiles" -ForegroundColor $(if ($renamedFiles -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  • Directories renamed to lowercase: $renamedDirs" -ForegroundColor $(if ($renamedDirs -gt 0) { "Yellow" } else { "Green" })
}

# Specifically fix the docs directory
Fix-CaseSensitivity -directory "docs"

Write-Host "`nCase sensitivity fix complete. Remember to commit these changes to ensure they're preserved on GitHub." -ForegroundColor Cyan
Write-Host "Run 'git add .' and 'git commit -m \"Fix case sensitivity issues for GitHub Pages\"' to save changes." -ForegroundColor Green 