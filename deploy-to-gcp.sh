#!/bin/bash
# Script to deploy the Python app to a GCP VM

# Configuration - Update these values
VM_INSTANCE_NAME="your-vm-instance-name"
VM_ZONE="us-central1-a"
PROJECT_ID="monitoring-project-483411"
LOCAL_DIR="."
REMOTE_DIR="~/sample-python-app"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying Python app to GCP VM...${NC}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed. Please install it first."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Set the project
echo -e "${YELLOW}Setting GCP project...${NC}"
gcloud config set project $PROJECT_ID

# Copy files to VM
echo -e "${YELLOW}Copying files to VM instance...${NC}"
gcloud compute scp --recurse $LOCAL_DIR/* $VM_INSTANCE_NAME:$REMOTE_DIR --zone=$VM_ZONE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Files successfully copied to VM!${NC}"
    echo -e "${YELLOW}Connecting to VM to set up the application...${NC}"
    
    # SSH into VM and set up the app
    gcloud compute ssh $VM_INSTANCE_NAME --zone=$VM_ZONE --command="
        cd $REMOTE_DIR
        echo 'Setting up Python virtual environment...'
        python3 -m venv venv
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
        echo 'Setup complete!'
        echo 'To run the app, use: python app.py'
    "
else
    echo "Error: Failed to copy files to VM"
    exit 1
fi

echo -e "${GREEN}Deployment complete!${NC}"
