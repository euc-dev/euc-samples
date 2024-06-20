function Get-TextBetweenTwoStrings ([string]$startPattern, [string]$endPattern, [string]$filePath){
    # Get content from the input file
    $fileContent = Get-Content -Path $filePath -Raw
    # Regular expression (Regex) of the given start and end patterns
    $pattern = '(?is){0}(.*?){1}' -f [regex]::Escape($startPattern), [regex]::Escape($endPattern)
    # Perform the Regex operation and output
    return [regex]::Match($fileContent,$pattern).Groups[1].Value.ToString()
}

$startPattern = '<!-- Summary Start -->'
$endPattern   = '<!-- Summary End -->'

$results = @{}
$files = Get-ChildItem -recurse -file -filter 'readme.md' -name
foreach ($f in $files) {
    # Write-Host("Working on $f") -ForegroundColor Green
    $match = Get-TextBetweenTwoStrings -startPattern $startPattern -endPattern $endPattern -filePath $f
    if ($match) {
        # Write-Host("match: $match") -ForegroundColor Yellow
        # $type=$match.GetType()
        # Write-Host("type(match): $type") -ForegroundColor Yellow
        $results.Add($f,$match)
    }
}

Write-Host("dict = { ") -ForegroundColor Green
foreach ($key in $results.keys) {
    $message = 'key={0} summary={1}' -f $key, $results[$key]
    Write-Host("  {`n    $message  }") -ForegroundColor Green
}
Write-Host("}") -ForegroundColor Green
