#!/bin/sh

echo "Detecting installed shells..."
echo "----------------------------"

for shell in /bin/*sh; do
    if [ -x "$shell" ]; then
        shell_name=$(basename "$shell")
        chmod +x detect.sh
        ./detect.sh "$shell"
    fi
done
