# Check structure of docs directory
Write-Host "Checking key files and directories..."

# Check if docs directory exists
if (Test-Path "docs") {
    Write-Host "✓ docs directory exists" -ForegroundColor Green
} else {
    Write-Host "✗ docs directory is missing!" -ForegroundColor Red
    exit
}

# Check if docs/images exists
if (Test-Path "docs/images") {
    Write-Host "✓ docs/images directory exists" -ForegroundColor Green
    
    # List subdirectories in images
    $imageDirs = Get-ChildItem -Path "docs/images" -Directory
    foreach ($dir in $imageDirs) {
        $fileCount = (Get-ChildItem -Path $dir.FullName -File | Measure-Object).Count
        Write-Host "  - $($dir.Name): $fileCount files" -ForegroundColor Gray
    }
} else {
    Write-Host "✗ docs/images directory is missing!" -ForegroundColor Red
}

# Check if docs/_next exists
if (Test-Path "docs/_next") {
    Write-Host "✓ docs/_next directory exists" -ForegroundColor Green
} else {
    Write-Host "✗ docs/_next directory is missing!" -ForegroundColor Red
}

# Check for key HTML files
if (Test-Path "docs/index.html") {
    Write-Host "✓ docs/index.html exists" -ForegroundColor Green
} else {
    Write-Host "✗ docs/index.html is missing!" -ForegroundColor Red
}

# Check for CNAME file
if (Test-Path "docs/CNAME") {
    $content = Get-Content -Path "docs/CNAME" -Raw
    Write-Host "✓ CNAME file exists with content: $content" -ForegroundColor Green
} else {
    Write-Host "✗ CNAME file is missing (required for custom domain)" -ForegroundColor Yellow
}

Write-Host "Check complete." 