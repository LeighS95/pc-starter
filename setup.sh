#!/bin/bash

# Detect OS and run the correct script
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    echo "Detected Windows. Running PowerShell setup..."
    powershell -ExecutionPolicy ByPass -File run.ps1
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS. Running Bash setup..."
    bash run.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux. Running Bash setup..."
    bash run.sh
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "Setup Complete!"