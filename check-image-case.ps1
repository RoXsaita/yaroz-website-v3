# PowerShell script to identify case sensitivity issues in image files
Write-Host "Checking for case sensitivity issues in image files..."

function Check-FileCaseSensitivity {
    param (
        [string]$directory
    )
    
    Write-Host "`nChecking directory: $directory" -ForegroundColor Cyan
    
    # Check if the directory exists
    if (-not (Test-Path $directory)) {
        Write-Host "Directory not found: $directory" -ForegroundColor Red
        return
    }
    
    # Get all image files in the directory and subdirectories
    $imageExtensions = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.webp", "*.svg", "*.mp4")
    $files = Get-ChildItem -Path $directory -Recurse -Include $imageExtensions
    
    # Count statistics
    $totalFiles = $files.Count
    $upperCaseFiles = 0
    $mixedCaseFiles = 0
    
    Write-Host "Found $totalFiles image files in $directory"
    
    # Group files by base name to identify duplicate names with different cases
    $fileGroups = $files | Group-Object -Property { $_.Name.ToLower() }
    
    # Check for duplicate filenames with different casing
    $caseSensitiveIssues = $fileGroups | Where-Object { $_.Count -gt 1 }
    if ($caseSensitiveIssues.Count -gt 0) {
        Write-Host "`nWARNING: Found $($caseSensitiveIssues.Count) case sensitivity duplicates:" -ForegroundColor Yellow
        foreach ($group in $caseSensitiveIssues) {
            Write-Host "  • Same name with different casing: $($group.Name)" -ForegroundColor Yellow
            foreach ($file in $group.Group) {
                Write-Host "    - $($file.FullName)" -ForegroundColor Gray
            }
        }
    }
    
    # Check for files with uppercase or mixed case
    Write-Host "`nChecking for uppercase or mixed case filenames:"
    foreach ($file in $files) {
        $lowercaseName = $file.Name.ToLower()
        
        if ($file.Name -ceq $file.Name.ToUpper()) {
            # All uppercase
            $upperCaseFiles++
            Write-Host "  • UPPERCASE: $($file.FullName)" -ForegroundColor Red
        }
        elseif ($file.Name -cne $lowercaseName) {
            # Mixed case
            $mixedCaseFiles++
            Write-Host "  • Mixed case: $($file.FullName)" -ForegroundColor Yellow
        }
    }
    
    # Check for directories with uppercase or mixed case
    $directories = Get-ChildItem -Path $directory -Directory -Recurse
    $upperCaseDirs = 0
    $mixedCaseDirs = 0
    
    Write-Host "`nChecking for uppercase or mixed case directory names:"
    foreach ($dir in $directories) {
        $lowercaseDirName = $dir.Name.ToLower()
        
        if ($dir.Name -ceq $dir.Name.ToUpper()) {
            # All uppercase
            $upperCaseDirs++
            Write-Host "  • UPPERCASE DIR: $($dir.FullName)" -ForegroundColor Red
        }
        elseif ($dir.Name -cne $lowercaseDirName) {
            # Mixed case
            $mixedCaseDirs++
            Write-Host "  • Mixed case DIR: $($dir.FullName)" -ForegroundColor Yellow
        }
    }
    
    # Summary
    Write-Host "`nSummary for $($directory):" -ForegroundColor Cyan
    Write-Host "  • Total image files: $totalFiles" -ForegroundColor White
    Write-Host "  • Files with UPPERCASE names: $upperCaseFiles" -ForegroundColor $(if ($upperCaseFiles -gt 0) { "Red" } else { "Green" })
    Write-Host "  • Files with Mixed Case names: $mixedCaseFiles" -ForegroundColor $(if ($mixedCaseFiles -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  • Directories with UPPERCASE names: $upperCaseDirs" -ForegroundColor $(if ($upperCaseDirs -gt 0) { "Red" } else { "Green" })
    Write-Host "  • Directories with Mixed Case names: $mixedCaseDirs" -ForegroundColor $(if ($mixedCaseDirs -gt 0) { "Yellow" } else { "Green" })
}

# Check key directories
Check-FileCaseSensitivity -directory "public/images"
Check-FileCaseSensitivity -directory "docs/images"

Write-Host "`nCase sensitivity check complete." -ForegroundColor Cyan 