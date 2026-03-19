# switch-account.ps1
# Usage: . ./github-issue-planner/scripts/switch-account.ps1

$accountFile = Join-Path (Get-Location) ".gh-account"

if (Test-Path $accountFile) {
    $account = (Get-Content $accountFile).Trim()
    
    try {
        # Dynamically fetch token from secure keyring
        $token = & "C:\Program Files\GitHub CLI\gh.exe" auth token -u $account 2>$null
        
        if ($token) {
            $env:GH_TOKEN = $token.Trim()
            Write-Host "✅ Account switched to [$account] using secure keyring." -ForegroundColor Green
        } else {
            Write-Host "❌ Could not fetch token for [$account]. Run 'gh auth login' first." -ForegroundColor Red
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "❌ .gh-account not found. Create one with your GitHub username." -ForegroundColor Yellow
}
