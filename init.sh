#!/bin/bash

# Utility functions
info_message() {
    echo -e "\033[1;36m[INFO] $1\033[0m"
}

success_message() {
    echo -e "\033[1;32m[SUCCESS] $1\033[0m"
}

warn_message() {
    echo -e "\033[1;33m[WARNING] $1\033[0m"
}

error_message() {
    echo -e "\033[1;31m[ERROR] $1\033[0m"
}

command_exists() {
    command -v "$1";
}

# Detect OS and Linux Distribution
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="Mac"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="Linux"
        if command -v lsb_release &>/dev/null; then
            DISTRO=$(lsb_release -is)
        elif [[ -f /etc/os-release ]]; then
            DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
        else
            DISTRO="Unknown"
        fi
    else
        error_message "Unsupported OS: $OSTYPE"
        exit 1
    fi

    export OS DISTRO
}

# Detect CPU Architecture
detect_arch() {
    ARCH=$(uname -m)
    # if [[ "$ARCH" == "x86_64" ]]; then
    #     ARCH="amd64"
    # elif [[ "$ARCH" == "aarch64" ]]; then
    #     ARCH="arm64"
    # elif [[ "$ARCH" == "armv7l" ]]; then
    #     ARCH="armv32"
    # else
    #     echo "Unsupported architecture: $ARCH"
    #     exit 1
    # fi
    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv32" ;;
        *) 
            error_message "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    export ARCH
}

# Function to display a menu and capture user choices
select_options() {
    # local options=("$@")
    # local selected=()
    # echo "Select options by entering numbers separated by spaces (e.g., 1 3 5):"
    # for i in "${!options[@]}"; do
    #     echo "$((i+1))) ${options[$i]}"
    # done
    # read -rp "Enter choices: " choices
    # for choice in $choices; do
    #     if (( choice >= 1 && choice <= ${#options[@]} )); then
    #         selected+=("${options[$((choice-1))]}")
    #     else
    #         echo "Invalid option: $choice. Skipping."
    #     fi
    # done

    # echo "${selected[@]}"  # Return selected options
    local options=("$@")
    local selected=()

    echo "Select options by entering numbers separated by spaces (e.g., 1 3 5):" >&2
    for i in "${!options[@]}"; do
        echo "$((i+1))) ${options[$i]}" >&2
    done

    read -rp "Enter choices: " choices
    choices=$(echo "$choices" | tr -s ' ')  # Remove extra spaces

    for choice in $choices; do
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
            selected+=("${options[$((choice-1))]}")
        else
            echo "Invalid selection: $choice. Skipping." >&2
        fi
    done

    # Return only selected values
    echo "${selected[@]}"
}