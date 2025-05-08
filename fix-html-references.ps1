# PowerShell script to fix HTML image references to match actual file case
Write-Host "Starting to fix HTML image references..."

# Function to get the actual casing of a file or directory
function Get-ActualPath {
    param (
        [string]$path
    )
    
    # Check if the path exists (case insensitive in Windows)
    if (Test-Path -Path $path) {
        # Get the actual item with its real casing
        $item = Get-Item -Path $path
        return $item.FullName
    }
    
    # If path doesn't exist, return original path
    return $path
}

# Function to fix image references in HTML files
function Fix-HtmlImageReferences {
    param (
        [string]$htmlFile
    )
    
    Write-Host "Processing HTML file: $htmlFile"
    
    # Read the HTML content
    $content = Get-Content -Path $htmlFile -Raw
    
    # Define the base directory for images
    $baseDir = "docs/images"
    
    # Create a map for directories with proper casing
    $dirMap = @{}
    if (Test-Path $baseDir) {
        $dirs = Get-ChildItem -Path $baseDir -Directory
        foreach ($dir in $dirs) {
            $dirMap[$dir.Name.ToLower()] = $dir.Name
        }
    }
    
    # Define regular expressions to find image references
    # Match patterns like: src="images/Cakes/cake_1.jpg" or href="images/Hero/Hero_video.mp4"
    $regex = '(src|href)="(images\/[^"]+)"'
    
    # Find all matches
    $matches = [regex]::Matches($content, $regex)
    
    Write-Host "Found $($matches.Count) image references"
    
    # For each match, check if the file exists and replace with proper casing
    foreach ($match in $matches) {
        $fullMatch = $match.Value
        $attr = $match.Groups[1].Value
        $imagePath = $match.Groups[2].Value
        
        # Parse the path into components
        $pathParts = $imagePath.Split('/')
        
        if ($pathParts.Length -ge 3) {
            $imagesDir = $pathParts[0]  # Should be "images"
            $categoryDir = $pathParts[1]  # e.g., "Cakes", "Hero"
            $filename = $pathParts[2]     # e.g., "cake_1.jpg"
            
            # Check if we have the correct casing for the category directory
            $correctCaseCategory = if ($dirMap.ContainsKey($categoryDir.ToLower())) {
                $dirMap[$categoryDir.ToLower()]
            } else {
                $categoryDir
            }
            
            # Get the actual file case if it exists
            $checkPath = Join-Path -Path "docs" -ChildPath (Join-Path -Path $imagesDir -ChildPath (Join-Path -Path $correctCaseCategory -ChildPath "*"))
            $matchingFiles = Get-ChildItem -Path $checkPath -File | Where-Object { $_.Name -ieq $filename }
            
            if ($matchingFiles -and $matchingFiles.Count -gt 0) {
                # Use the first match (should be only one)
                $correctCaseFilename = $matchingFiles[0].Name
                
                # Construct the correct path
                $correctPath = "$imagesDir/$correctCaseCategory/$correctCaseFilename"
                
                # Replace in the content
                $newAttr = "$attr=""$correctPath"""
                $content = $content -replace [regex]::Escape($fullMatch), $newAttr
                
                Write-Host "  Fixed: $imagePath -> $correctPath"
            } else {
                Write-Host "  Warning: Could not find match for $imagePath" -ForegroundColor Yellow
            }
        }
    }
    
    # Write the modified content back to the file
    Set-Content -Path $htmlFile -Value $content
    Write-Host "Updated $htmlFile"
}

# Process all HTML files in the docs directory
$htmlFiles = Get-ChildItem -Path "docs" -Filter "*.html" -Recurse
foreach ($file in $htmlFiles) {
    Fix-HtmlImageReferences -htmlFile $file.FullName
}

Write-Host "HTML reference fixing complete." 