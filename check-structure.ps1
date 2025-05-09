# PowerShell script to check for the existence of key files and directories in the docs folder
Write-Host "Checking structure of docs directory for GitHub Pages deployment..."

# Check if the docs directory exists
if (-not (Test-Path "docs")) {
    Write-Host "ERROR: The docs directory does not exist!" -ForegroundColor Red
    exit
}

# Check if images folder exists
if (-not (Test-Path "docs/images")) {
    Write-Host "ERROR: The images directory does not exist in docs!" -ForegroundColor Red
} else {
    Write-Host "✓ Found images directory" -ForegroundColor Green
    
    # Check key subdirectories
    $subdirs = @("cakes", "sweets", "catering", "aboutus", "hero", "placeholders")
    foreach ($subdir in $subdirs) {
        if (Test-Path "docs/images/$subdir") {
            $count = (Get-ChildItem -Path "docs/images/$subdir" -File | Measure-Object).Count
            Write-Host "  ✓ Found $subdir directory with $count files" -ForegroundColor Green
            
            # List first few files
            $files = Get-ChildItem -Path "docs/images/$subdir" -File | Select-Object -First 3
            foreach ($file in $files) {
                Write-Host "    - $($file.Name)" -ForegroundColor Gray
            }
            if ($count -gt 3) {
                Write-Host "    - ... and $($count - 3) more" -ForegroundColor Gray
            }
        } else {
            Write-Host "  ✗ Missing $subdir directory!" -ForegroundColor Red
        }
    }
}

# Check if _next folder exists
if (-not (Test-Path "docs/_next")) {
    Write-Host "ERROR: The _next directory does not exist in docs!" -ForegroundColor Red
} else {
    Write-Host "✓ Found _next directory" -ForegroundColor Green
    
    # Check static chunks
    if (Test-Path "docs/_next/static/chunks") {
        $count = (Get-ChildItem -Path "docs/_next/static/chunks" -Recurse -File | Measure-Object).Count
        Write-Host "  ✓ Found static/chunks with $count files" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing static/chunks directory!" -ForegroundColor Red
    }
    
    # Check CSS files
    if (Test-Path "docs/_next/static/css") {
        $count = (Get-ChildItem -Path "docs/_next/static/css" -File | Measure-Object).Count
        Write-Host "  ✓ Found static/css with $count files" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing static/css directory!" -ForegroundColor Red
    }
}

# Check for index.html
if (Test-Path "docs/index.html") {
    Write-Host "✓ Found index.html" -ForegroundColor Green
} else {
    Write-Host "ERROR: index.html is missing from docs!" -ForegroundColor Red
}

# Check for 404.html
if (Test-Path "docs/404.html") {
    Write-Host "✓ Found 404.html" -ForegroundColor Green
} else {
    Write-Host "✗ Missing 404.html" -ForegroundColor Yellow
}

# Check if CNAME file exists (indicates custom domain)
if (Test-Path "docs/CNAME") {
    $domain = Get-Content -Path "docs/CNAME" -Raw
    Write-Host "✓ Found CNAME file with domain: $domain" -ForegroundColor Green
} else {
    Write-Host "✗ No CNAME file found (needed for custom domain)" -ForegroundColor Yellow
}

Write-Host "`nStructure check complete." 