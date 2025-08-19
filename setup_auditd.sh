#!/bin/bash
# Full auditd setup for logging execve calls from pentest user
# Includes installation, rules, and log rotation

# ==== CONFIGURABLE VARIABLES ====
USER_TO_LOG="pentest"                   # username you want to log
TAG_NAME="pentest_deconfliction"        # tag used for ausearch/aureport filtering
MAX_LOG_MB=10                           # size per logfile (MB)
NUM_LOGS=100                            # number of rotated logs to keep
# Total storage = MAX_LOG_MB * NUM_LOGS  (default 100MB * 100 = 10GB)

# ==== Install and Configure Auditd ====
echo "[*] Installing auditd..."
apt-get update -y
apt-get install -y auditd audispd-plugins

echo "[*] Enabling and starting auditd..."
systemctl enable auditd
systemctl start auditd

# Get UID of target user
USER_UID=$(id -u "$USER_TO_LOG" 2>/dev/null)
if [ -z "$USER_UID" ]; then
  echo "[!] User $USER_TO_LOG not found. Exiting."
  exit 1
fi


# Create Audit Rules
RULE_FILE="/etc/audit/rules.d/${TAG_NAME}.rules"

echo "[*] Writing auditd rules to $RULE_FILE..."
cat <<EOF > "$RULE_FILE"
# ==== Execve logging for root ====
#-a always,exit -F arch=b64 -S execve -F auid=0 -k $TAG_NAME
#-a always,exit -F arch=b32 -S execve -F auid=0 -k $TAG_NAME

# ==== Execve logging for $USER_TO_LOG (UID=$USER_UID) ====
-a always,exit -F arch=b64 -S execve -F auid=$USER_UID -k $TAG_NAME
-a always,exit -F arch=b32 -S execve -F auid=$USER_UID -k $TAG_NAME
EOF

# Ensure pam_loginuid is globally enabled via common-session
if ! grep -q "pam_loginuid.so" /etc/pam.d/common-session; then
    echo "# Set the loginuid process attribute." >> /etc/pam.d/common-session
    echo "session    required     pam_loginuid.so" >> /etc/pam.d/common-session
fi

# Configure Max Log Size and Rotation
echo "[*] Configuring auditd log rotation (max ${MAX_LOG_MB}MB × ${NUM_LOGS} logs)..."
sed -i "s/^max_log_file.*/max_log_file = $MAX_LOG_MB/" /etc/audit/auditd.conf || echo "max_log_file = $MAX_LOG_MB" >> /etc/audit/auditd.conf
sed -i "s/^max_log_file_action.*/max_log_file_action = ROTATE/" /etc/audit/auditd.conf || echo "max_log_file_action = ROTATE" >> /etc/audit/auditd.conf
sed -i "s/^num_logs.*/num_logs = $NUM_LOGS/" /etc/audit/auditd.conf || echo "num_logs = $NUM_LOGS" >> /etc/audit/auditd.conf


# Reload Auditd
echo "[*] Reloading audit rules..."
augenrules --load
systemctl restart auditd


