#!/bin/bash
# Script to initialize git repository and push to GitHub

# Configuration - Update these values
GITHUB_REPO_URL=""
REPO_NAME="sample-python-app"
BRANCH="main"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying to GitHub...${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed. Please install it first.${NC}"
    echo "Visit: https://git-scm.com/downloads"
    exit 1
fi

# Initialize git repository if not already initialized
if [ ! -d .git ]; then
    echo -e "${YELLOW}Initializing git repository...${NC}"
    git init
    git branch -M $BRANCH
else
    echo -e "${GREEN}Git repository already initialized.${NC}"
fi

# Add all files
echo -e "${YELLOW}Adding files to git...${NC}"
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}No changes to commit.${NC}"
else
    # Commit changes
    echo -e "${YELLOW}Committing changes...${NC}"
    git commit -m "Initial commit: Sample Python Flask REST API"
fi

# Check if remote exists
if git remote | grep -q "^origin$"; then
    echo -e "${GREEN}Remote 'origin' already exists.${NC}"
    if [ -z "$GITHUB_REPO_URL" ]; then
        CURRENT_REMOTE=$(git remote get-url origin)
        echo -e "${YELLOW}Current remote: $CURRENT_REMOTE${NC}"
        read -p "Do you want to push to the existing remote? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exiting. You can set a new remote manually or update GITHUB_REPO_URL in the script."
            exit 0
        fi
    else
        git remote set-url origin "$GITHUB_REPO_URL"
        echo -e "${GREEN}Remote URL updated.${NC}"
    fi
else
    if [ -z "$GITHUB_REPO_URL" ]; then
        echo -e "${RED}Error: GITHUB_REPO_URL is not set.${NC}"
        echo "Please set GITHUB_REPO_URL in the script or run:"
        echo "  git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
        echo "  git push -u origin $BRANCH"
        exit 1
    else
        echo -e "${YELLOW}Adding remote origin...${NC}"
        git remote add origin "$GITHUB_REPO_URL"
    fi
fi

# Push to GitHub
echo -e "${YELLOW}Pushing to GitHub...${NC}"
git push -u origin $BRANCH

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Successfully pushed to GitHub!${NC}"
else
    echo -e "${RED}Error: Failed to push to GitHub.${NC}"
    echo "You may need to:"
    echo "  1. Create a repository on GitHub first"
    echo "  2. Set up authentication (SSH keys or personal access token)"
    echo "  3. Update GITHUB_REPO_URL in the script"
    exit 1
fi

echo -e "${GREEN}Deployment complete!${NC}"
