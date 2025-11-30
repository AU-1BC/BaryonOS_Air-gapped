#!/bin/bash

# === SETTINGS ===
REPO_URL="https://github.com/AU-1BC/BaryonOS_Air-gapped.git"
WORK_DIR="/usr/local/BaryonOSUpdate"
TEMP_DIR="/tmp/BaryonOSUpdate-temp"

# === PREPARE DIRECTORIES ===
mkdir -p "$WORK_DIR"
rm -rf "$TEMP_DIR"
git clone --depth=1 "$REPO_URL" "$TEMP_DIR" || {
    echo "Git clone failed"
    exit 1
}

# === CHECK LOCAL & REMOTE VERSION ===
LOCAL_VER_FILE="$WORK_DIR/version.txt"
REMOTE_VER_FILE="$TEMP_DIR/version.txt"

if [[ ! -f "$LOCAL_VER_FILE" ]]; then
    echo "0.0.0" > "$LOCAL_VER_FILE"
fi

LOCAL_VERSION=$(cat "$LOCAL_VER_FILE")
REMOTE_VERSION=$(cat "$REMOTE_VER_FILE")

echo "Local Version: $LOCAL_VERSION"
echo "Remote Version: $REMOTE_VERSION"

# === VERSION COMPARISON FUNCTION ===
version_greater() {
    [[ $1 == $2 ]] && return 1
    IFS='.' read -r A1 A2 A3 <<< "$1"
    IFS='.' read -r B1 B2 B3 <<< "$2"
    
    if (( A2 > B2 )); then return 0; fi
    if (( A2 < B2 )); then return 1; fi

    if (( A1 > B1 )); then return 0; fi
    if (( A1 < B1 )); then return 1; fi

    if (( A3 > B3 )); then return 0; fi
    return 1
}

# === IF UPDATE AVAILABLE ===
if version_greater "$REMOTE_VERSION" "$LOCAL_VERSION"; then
    echo ">> New update found. Running update..."

    cp "$TEMP_DIR/run.sh" "$WORK_DIR/run.sh"
    chmod +x "$WORK_DIR/run.sh"
    bash "$WORK_DIR/run.sh"

    # Keep version.txt only
    echo "$REMOTE_VERSION" > "$LOCAL_VER_FILE"
    ls | grep -v "version.txt" | xargs rm -rf

    echo "Update complete. Version updated to $REMOTE_VERSION"
else
    echo ">> No update available."
fi

# === CLEANUP ===
rm -rf "$TEMP_DIR"
exit 0
