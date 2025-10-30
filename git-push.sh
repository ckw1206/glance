#!/bin/bash

WORKDIR="/home/opc/glance"
cd "$WORKDIR" || {
    echo "[ERROR] Failed to change directory to $WORKDIR"
    exit 1
}

# Logging setup
LOG_FILE="./logs/glance_backup_$(date +'%Y%m%d').log"
mkdir -p ./logs

log() {
    local level="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
}

# Determine backup branch name (MMDD)
BRANCH_NAME=$(date +'%m%d')

log "INFO" "Stopping Glance related services..."
if docker compose down >>"$LOG_FILE" 2>&1; then
    log "OK" "Services stopped successfully."
else
    log "ERROR" "Failed to stop services with docker compose."
    exit 1
fi

# Prepare Git backup branch
log "INFO" "Preparing Git branch for backup: $BRANCH_NAME"

# Fetch latest data to englance clean switch
/usr/bin/sudo /usr/bin/git fetch origin >>"$LOG_FILE" 2>&1

# Check if branch exists remotely
if /usr/bin/sudo /usr/bin/git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    log "INFO" "Branch $BRANCH_NAME exists. Checking out and updating..."
    /usr/bin/sudo /usr/bin/git checkout "$BRANCH_NAME" >>"$LOG_FILE" 2>&1
    /usr/bin/sudo /usr/bin/git pull origin "$BRANCH_NAME" >>"$LOG_FILE" 2>&1
else
    log "INFO" "Branch $BRANCH_NAME does not exist. Creating new branch..."
    /usr/bin/sudo /usr/bin/git checkout -B "$BRANCH_NAME" >>"$LOG_FILE" 2>&1
fi

# Commit and push changes
log "INFO" "Committing changes..."
/usr/bin/sudo /usr/bin/git add . >>"$LOG_FILE" 2>&1
/usr/bin/sudo /usr/bin/git commit -m "Daily backup $(date +'%Y-%m-%d')" >>"$LOG_FILE" 2>&1 || log "INFO" "No changes to commit."

source ./.env

log "INFO" "Pushing changes to GitHub branch $BRANCH_NAME..."
if /usr/bin/sudo /usr/bin/git push -f origin "$BRANCH_NAME" >>"$LOG_FILE" 2>&1; then
    log "OK" "Backup pushed successfully to branch $BRANCH_NAME."
else
    log "ERROR" "Failed to push to GitHub."
    exit 1
fi

# Restart services
log "INFO" "Restarting Glance services..."
if docker compose up -d >>"$LOG_FILE" 2>&1; then
    log "OK" "Services restarted successfully."
else
    log "ERROR" "Failed to restart services."
    exit 1
fi

# Optional: clean up old local log files older than 30 days
find ./logs -type f -name "glance_backup_*.log" -mtime +30 -exec rm {} \;

log "DONE" "Backup process completed for branch $BRANCH_NAME."

exit 0

