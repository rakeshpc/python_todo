# Deploying to GCP VM

This guide explains how to transfer and deploy this Python application to a Google Cloud Platform (GCP) VM instance.

## Prerequisites

1. **GCP Account**: You need a Google Cloud Platform account
2. **gcloud CLI**: Install the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
3. **VM Instance**: Create a GCP VM instance if you haven't already

## Option 1: Using gcloud compute scp (Recommended)

### Step 1: Authenticate with GCP

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Step 2: Copy files to VM

```bash
# Replace with your values
VM_NAME="your-vm-instance-name"
ZONE="us-central1-a"

# Copy all files to the VM
gcloud compute scp --recurse . $VM_NAME:~/sample-python-app --zone=$ZONE
```

### Step 3: SSH into the VM and set up

```bash
# SSH into the VM
gcloud compute ssh $VM_NAME --zone=$ZONE

# Once inside the VM:
cd ~/sample-python-app
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 4: Run the application

```bash
# Inside the VM
python app.py
```

To run in the background:
```bash
nohup python app.py > app.log 2>&1 &
```

## Option 2: Using Deployment Scripts

### For Linux/Mac:

1. Edit `deploy-to-gcp.sh` and update the configuration variables:
   - `VM_INSTANCE_NAME`
   - `VM_ZONE`
   - `PROJECT_ID`

2. Make the script executable:
   ```bash
   chmod +x deploy-to-gcp.sh
   ```

3. Run the script:
   ```bash
   ./deploy-to-gcp.sh
   ```

### For Windows (PowerShell):

1. Edit `deploy-to-gcp.ps1` and update the configuration variables:
   - `$VM_INSTANCE_NAME`
   - `$VM_ZONE`
   - `$PROJECT_ID`

2. Run the script:
   ```powershell
   .\deploy-to-gcp.ps1
   ```

## Option 3: Using Git (Alternative)

If your code is in a Git repository:

### On your local machine:
```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### On the GCP VM:
```bash
# SSH into the VM
gcloud compute ssh $VM_NAME --zone=$ZONE

# Clone the repository
git clone YOUR_REPO_URL
cd YOUR_REPO_NAME

# Set up the environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

## Option 4: Using Cloud Storage

1. **Upload to Cloud Storage:**
   ```bash
   # Create a bucket (one-time)
   gsutil mb gs://your-bucket-name

   # Upload files
   gsutil -m cp -r . gs://your-bucket-name/sample-python-app/
   ```

2. **Download on VM:**
   ```bash
   # SSH into VM
   gcloud compute ssh $VM_NAME --zone=$ZONE

   # Download files
   gsutil -m cp -r gs://your-bucket-name/sample-python-app ~/
   cd ~/sample-python-app
   ```

## Firewall Configuration

To access the Flask app from outside the VM, you need to:

1. **Create a firewall rule:**
   ```bash
   gcloud compute firewall-rules create allow-flask-app \
     --allow tcp:5000 \
     --source-ranges 0.0.0.0/0 \
     --description "Allow Flask app on port 5000"
   ```

2. **Add a network tag to your VM** (if using tags):
   ```bash
   gcloud compute instances add-tags $VM_NAME \
     --tags flask-app \
     --zone=$ZONE
   ```

## Running as a Service (systemd)

Create a systemd service for production:

1. **Create service file on VM:**
   ```bash
   sudo nano /etc/systemd/system/flask-app.service
   ```

2. **Add the following content:**
   ```ini
   [Unit]
   Description=Flask Python App
   After=network.target

   [Service]
   User=your-username
   WorkingDirectory=/home/your-username/sample-python-app
   Environment="PATH=/home/your-username/sample-python-app/venv/bin"
   ExecStart=/home/your-username/sample-python-app/venv/bin/python app.py
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. **Enable and start the service:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable flask-app
   sudo systemctl start flask-app
   sudo systemctl status flask-app
   ```

## Troubleshooting

- **Permission denied**: Ensure your user has SSH access to the VM
- **Port 5000 not accessible**: Check firewall rules and VM network tags
- **Python not found**: Install Python 3 on the VM: `sudo apt-get update && sudo apt-get install python3 python3-pip`
- **Module not found**: Ensure virtual environment is activated and requirements are installed

## Quick Reference Commands

```bash
# List VM instances
gcloud compute instances list

# Copy single file
gcloud compute scp app.py $VM_NAME:~/sample-python-app/ --zone=$ZONE

# Copy entire directory
gcloud compute scp --recurse . $VM_NAME:~/sample-python-app --zone=$ZONE

# SSH into VM
gcloud compute ssh $VM_NAME --zone=$ZONE

# View VM logs (if using systemd)
sudo journalctl -u flask-app -f
```
