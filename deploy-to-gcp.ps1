# PowerShell script to deploy the Python app to a GCP VM

# Configuration - Update these values
$VM_INSTANCE_NAME = "your-vm-instance-name"
$VM_ZONE = "us-central1-a"
$PROJECT_ID = "monitoring-project-483411"
$LOCAL_DIR = "."
$REMOTE_DIR = "~/sample-python-app"

Write-Host "Deploying Python app to GCP VM..." -ForegroundColor Green

# Check if gcloud is installed
try {
    $null = Get-Command gcloud -ErrorAction Stop
} catch {
    Write-Host "Error: gcloud CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://cloud.google.com/sdk/docs/install" -ForegroundColor Yellow
    exit 1
}

# Set the project
Write-Host "Setting GCP project..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID

# Copy files to VM
Write-Host "Copying files to VM instance..." -ForegroundColor Yellow
gcloud compute scp --recurse $LOCAL_DIR/* $VM_INSTANCE_NAME`:$REMOTE_DIR --zone=$VM_ZONE

if ($LASTEXITCODE -eq 0) {
    Write-Host "Files successfully copied to VM!" -ForegroundColor Green
    Write-Host "Connecting to VM to set up the application..." -ForegroundColor Yellow
    
    # SSH into VM and set up the app
    $setupCommand = @"
cd $REMOTE_DIR
echo 'Setting up Python virtual environment...'
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
echo 'Setup complete!'
echo 'To run the app, use: python app.py'
"@
    
    gcloud compute ssh $VM_INSTANCE_NAME --zone=$VM_ZONE --command=$setupCommand
    
    Write-Host "Deployment complete!" -ForegroundColor Green
} else {
    Write-Host "Error: Failed to copy files to VM" -ForegroundColor Red
    exit 1
}
