#!/bin/sh

if [ -z "$1" ]; then
    echo "Usage: $0 <shell-type>"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    echo "cURL is not installed! Installing..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y curl
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y curl
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y curl
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy curl
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y curl
    else
        echo "Error: Could not find package manager. Please install curl manually."
        exit 1
    fi
fi

# Check for jq
if ! command -v jq >/dev/null 2>&1; then
    echo "jq is not installed! Installing..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt install -y jq
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y jq
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y jq
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy jq
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y jq
    else
        echo "Error: Could not install jq. Please install manually."
        exit 1
    fi
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../../" && pwd)"

# Read and parse version info from local file
json_data=$(cat "$BASE_DIR/_versions")

# Extract version and create compressed format (a.v100)
version_array=$(echo "$json_data" | jq -r '.linux.v[]' | tr '\n' ' ')
compressed_version="a.v100"

# Get shell-specific filename based on shell type
shell_file=$(echo "$json_data" | jq -r ".linux.f.$1")

if [ -z "$shell_file" ]; then
    echo "Error: No file specified for shell type $1"
    exit 1
fi

# Now we have the correct filename like ba.a.v100.sh, z.a.v100.sh, or k.a.v100.sh
echo "Using shell script: $shell_file"

# Switch to the specified shell
if [ -x "/bin/$1" ]; then
    exec "/bin/$1"
else
    echo "Error: Shell /bin/$1 not found or not executable"
    exit 1
fi


