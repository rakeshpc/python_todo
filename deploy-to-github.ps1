# PowerShell script to initialize git repository and push to GitHub

# Configuration - Update these values
$GITHUB_REPO_URL = ""
$REPO_NAME = "sample-python-app"
$BRANCH = "main"

Write-Host "Deploying to GitHub..." -ForegroundColor Green

# Check if git is installed
try {
    $null = Get-Command git -ErrorAction Stop
} catch {
    Write-Host "Error: git is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://git-scm.com/downloads" -ForegroundColor Yellow
    exit 1
}

# Initialize git repository if not already initialized
if (-not (Test-Path .git)) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
    git branch -M $BRANCH
} else {
    Write-Host "Git repository already initialized." -ForegroundColor Green
}

# Add all files
Write-Host "Adding files to git..." -ForegroundColor Yellow
git add .

# Check if there are changes to commit
$status = git status --porcelain
if ($status) {
    # Commit changes
    Write-Host "Committing changes..." -ForegroundColor Yellow
    git commit -m "Initial commit: Sample Python Flask REST API"
} else {
    Write-Host "No changes to commit." -ForegroundColor Yellow
}

# Check if remote exists
$remotes = git remote
if ($remotes -contains "origin") {
    Write-Host "Remote 'origin' already exists." -ForegroundColor Green
    if ([string]::IsNullOrWhiteSpace($GITHUB_REPO_URL)) {
        $currentRemote = git remote get-url origin
        Write-Host "Current remote: $currentRemote" -ForegroundColor Yellow
        $response = Read-Host "Do you want to push to the existing remote? (y/n)"
        if ($response -ne "y" -and $response -ne "Y") {
            Write-Host "Exiting. You can set a new remote manually or update GITHUB_REPO_URL in the script."
            exit 0
        }
    } else {
        git remote set-url origin $GITHUB_REPO_URL
        Write-Host "Remote URL updated." -ForegroundColor Green
    }
} else {
    if ([string]::IsNullOrWhiteSpace($GITHUB_REPO_URL)) {
        Write-Host "Error: GITHUB_REPO_URL is not set." -ForegroundColor Red
        Write-Host "Please set GITHUB_REPO_URL in the script or run:" -ForegroundColor Yellow
        Write-Host "  git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
        Write-Host "  git push -u origin $BRANCH"
        exit 1
    } else {
        Write-Host "Adding remote origin..." -ForegroundColor Yellow
        git remote add origin $GITHUB_REPO_URL
    }
}

# Push to GitHub
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push -u origin $BRANCH

if ($LASTEXITCODE -eq 0) {
    Write-Host "Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host "Error: Failed to push to GitHub." -ForegroundColor Red
    Write-Host "You may need to:" -ForegroundColor Yellow
    Write-Host "  1. Create a repository on GitHub first"
    Write-Host "  2. Set up authentication (SSH keys or personal access token)"
    Write-Host "  3. Update GITHUB_REPO_URL in the script"
    exit 1
}

Write-Host "Deployment complete!" -ForegroundColor Green
