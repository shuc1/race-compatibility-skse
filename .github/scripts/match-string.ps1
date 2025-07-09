function Match-String {
    param (
        [string]$content,
        [string]$pattern
    )

    $regex = [regex]::new($pattern)
    $match = $regex.Match($content)

    if ($match.Success) {
        return $match.Groups[1].Value
    } else {
        Write-Host "❌ Pattern '$pattern' not found in content."
        return $null
    }
}