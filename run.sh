#!/bin/bash

# Ensure script is executed with proper permissions
if [[ $(id -u) -eq 0 ]]; then
    echo "Running as root. This script should be run as a normal user with sudo where necessary."
    exit 1
fi

if ! command -v curl 2>&1 >/dev/null; then
    echo "Curl no found"
else
    echo "curl found"
fi

# Define local and remote paths for utils.sh
SCRIPT_DIR=$(dirname "$(realpath "$0")")
LOCAL_UTILS="$SCRIPT_DIR/init.sh"
REMOTE_UTILS="https://raw.githubusercontent.com/LeighS95/pc-starter/main/init.sh"

# Load utils.sh (either locally or remotely)
if [[ -f "$LOCAL_UTILS" ]]; then
    echo "Loading local init.sh..."
    source "$LOCAL_UTILS"
else
    echo "Downloading init.sh from remote..."
    if command -v curl; then
        echo "Running Curl..."
        curl -fsSL "$REMOTE_UTILS" -o /tmp/init.sh
        CURL_EXIT_CODE=$?  # Capture exit status of curl
        echo "Curl failed with exit code $CURL_EXIT_CODE"
    elif command -v wget; then
        echo "Running wget"
        wget -q "$REMOTE_UTILS" -O /tmp/init.sh
        WGET_EXIT_CODE=$?  # Capture exit status of wget
        echo "Wget failed with exit code $WGET_EXIT_CODE"
    else
        echo "Neither curl nor wget is available. Cannot download init.sh."
        exit 1
    fi
    source /tmp/init.sh
fi

info_message "Detecting OS and Architecture..."
detect_os
detect_arch
info_message "Running setup on $OS ($DISTRO $ARCH)..."

# Determine package manager
USE_NIX=false
if [[ "$OS" == "Mac" ]]; then
    echo "Select a package manager:"
    select PACKAGE_MANAGER_CHOICE in "Homebrew" "Nix"; do
        case $PACKAGE_MANAGER_CHOICE in
            "Nix")
                USE_NIX=true
                if ! command_exists nix; then
                    info_message "Installing Nix package manager..."
                    curl -L https://nixos.org/nix/install | sh
                    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
                    export PATH="$HOME/.nix-profile/bin:$PATH"
                fi
                break;;
            "Homebrew")
                if ! command_exists brew; then
                    info_message "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                    export PATH="/opt/homebrew/bin:$PATH"
                fi
                break;;
            *) error_message "Invalid option. Please select 1 or 2.";;
        esac
    done
elif [[ "$OS" == "Linux" ]]; then
    echo "Select a package manager:"
    select PACKAGE_MANAGER_CHOICE in "Default ($DISTRO)" "Nix"; do
        case $PACKAGE_MANAGER_CHOICE in
            "Nix")
                USE_NIX=true
                # Nix requires xz package
                if ! command_exists xz; then
                    info_message "Installing xz..."
                    sudo apt install -y xz-utils
                fi
                if ! command_exists nix; then
                    info_message "Installing Nix package manager..."
                    sh <(curl -L https://nixos.org/nix/install) --daemon
                    # . "$HOME/.nix-profile/etc/profile.d/nix.sh"
                    info_message "Adding nix to path and updating source..."
                    . /etc/profile.d/nix.sh
                    export PATH="$HOME/.nix-profile/bin:$PATH"
                    echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.bashrc
                    echo 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.zshrc
                    source ~/.bashrc || source ~/.zshrc

                    # Enable features
                    info_message "Enabling nix features"
                    mkdir -p ~/.config/nix
                    echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
                    source /etc/profile.d/nix.sh || source ~/.nix-profile/etc/profile.d/nix.sh
                fi
                break;;
            "Default ($DISTRO)")
                break;;
            *) error_message "Invalid option. Please select 1 or 2.";;
        esac
    done
fi

# Validate package manager selection
if ! command_exists brew && ! command_exists nix && ! command_exists apt && ! command_exists dnf && ! command_exists pacman && ! command_exists zypper; then
    error_message "No supported package manager found. Exiting."
    exit 1
fi

install_nix() {
    sudo -i nix profile install "nixpkgs#$1"
}

# Set package manager command
if [[ "$USE_NIX" == true ]]; then
    PKG_MANAGER="install_nix"
else
    if [[ "$OS" == "Mac" ]]; then
        PKG_MANAGER="brew install"
    elif [[ "$OS" == "Linux" ]]; then
        if command_exists apt; then
            PKG_MANAGER="sudo apt install -y"
            UPDATE_CMD="sudo apt update -y"
        elif command_exists dnf; then
            PKG_MANAGER="sudo dnf install -y"
            UPDATE_CMD="sudo dnf check-update"
        elif command_exists pacman; then
            PKG_MANAGER="sudo pacman -S --noconfirm"
            UPDATE_CMD="sudo pacman -Sy"
        elif command_exists zypper; then
            PKG_MANAGER="sudo zypper install -y"
            UPDATE_CMD="sudo zypper refresh"
        else
            error_message "Unsupported Linux package manager. Install software manually."
            exit 1
        fi
        info_message "Updating package lists..."
        eval "$UPDATE_CMD"
    fi
fi

info_message "Using $PACKAGE_MANAGER_CHOICE"

# Install Chrome
read -p "Do you want to install Google Chrome? [y/n]: " INSTALL_CHROME
if [[ "$INSTALL_CHROME" =~ ^[Yy]$ ]]; then
    info_message "Installing Chrome..."
    if [[ "$USE_NIX" == true ]]; then
        eval "$PKG_MANAGER google-chrome" || { error_message "Chrome installation failed"; exit 1; }
    elif command_exists brew; then
        eval "$PKG_MANAGER --cask google-chrome" || { error_message "Chrome installation failed"; exit 1; }
    elif command_exists apt; then
        wget -qO chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && sudo dpkg -i chrome.deb && rm chrome.deb || { error_message "Chrome installation failed"; exit 1; }
    elif command_exists dnf; then
        sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm || { error_message "Chrome installation failed"; exit 1; }
    elif command_exists pacman; then
        sudo pacman -S --noconfirm google-chrome || { error_message "Chrome installation failed"; exit 1; }
    else
        error_message "Chrome installation not supported on this system."
    fi

    success_message "Chrome Installed!"
fi

# Check for git and then Install git
if command_exists git; then
    info_message "Installing git..."
    if [[ "$USE_NIX" == true ]]; then
        eval "$PKG_MANAGER git"
    else
        eval "$PKG_MANAGER git-all"
else
    info_message "Git is already installed."
fi

# Install tooling
echo "Select tools"
if [[ "$OS" == "Mac" ]]; then
    tools=("fzf" "fselect" "jq" "tmux")
else
    tools=("fzf" "jq" "tmux")
fi
selected_tools=$(select_options "${tools[@]}")

info_message "Installing tools - $selected_tools"
for tool in $selected_tools; do
    info_message "Installing $tool..."
    eval "$PKG_MANAGER $tool" || { error_message "$tool installation failed"; exit 1; }
    success_message "Installed $tool!"
done

# Intall terminals
echo "Selecting terminal emulators"
terminals=("Ghostty" "Kitty")
selected_terminals=$(select_options "${terminals[@]}")

info_message "Installing - $selected_terminals"
for term in $selected_terminals; do
    info_message "Installing $term"
    case $term in
        "Ghostty")
            if [[ "$PACKAGE_MANAGER" == "homebrew" ]]; then
                eval "$PKG_MANAGER --cask ghostty" || { error_message "ghostty installation failed"; exit 1; }
            else
                eval "$PKG_MANAGER ghostty" || { error_message "ghostty installation failed"; exit 1; }
            fi
            ;;
        "Kitty")
            eval "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"|| { error_message "Kitty installation failed"; exit 1; }
            ;;
    esac

    success_message "$tool Installed!"
done

# Install programming languages
echo "Selecting programming languages"
langs=("Python" "Node" "Rust" "Golang" "Ruby" "Java" "Kotlin" "C" "Cpp" "Zig" "Elixir")
selected_langs=$(select_options "${langs[@]}")

intall_sdkman() {
    info_message "Installing SDKMAN..."
    
    # Download and install SDKMAN
    curl -s "https://get.sdkman.io" | bash || { echo "SDKMAN installation failed!"; exit 1; }

    # Ensure SDKMAN init script exists before sourcing
    if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        # Add SDKMAN to shell startup files
        echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.bashrc
        echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> ~/.bashrc
        echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.zshrc
        echo '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"' >> ~/.zshrc

        # Reload shell configuration
        source ~/.bashrc || source ~/.zshrc

        # Verify installation
        sdk version || { info_message "SDKMAN installation verification failed!"; }

        success_message "SDKMAN successfully installed and configured!"
    else
        error_message "SDKMAN installation failed: Init script not found!"
    fi
}

info_message "Installing languages..."
for lang in $selected_langs; do
    info_message "Installing $lang..."
    case $lang in
        "Python")
            eval "$PKG_MANAGER python3.6"
            ;;
        "Node")
            # eval "$PKG_MANAGER nodejs"
            eval "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
            eval "source ./bashrc"
            eval "nvm install --lts"
            ;;
        "Rust")
            eval "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
            eval "source ./bashrc"
            eval "rustup update"
            ;;
        "Golang")
            eval "$PKG_MANAGER golang-go"
            ;;
        "Ruby")
            if [[ "$PKG_MANAGER" != "Nix" ]]; then
                if command_exists apt; then
                    eval "$PKG_MANAGER ruby-full"
                else
                    eval "$PKG_MANAGER ruby"
                fi
            else
                eval "$PKG_MANAGER ruby"
            fi
            ;;
        "PHP")
            eval "$PKG_MANAGER php"
            ;;
        "Java")
            if ! command_exists sdkman; then
                intall_sdkman
            fi
            eval "sdk install java" || { echo "Java installation failed"; }
            ;;
        "Kotlin")
            if ! command_exists sdkman; then
                intall_sdkman
            fi
            eval "sdk install kotlin"|| { echo "Kotlin installation failed"; }
            ;;
        "C")
            eval "$PKG_MANAGER gcc" || { echo "GCC installation failed"; }
            ;;
        "Cpp")
            eval "$PKG_MANAGER g++" || { echo "G++ installation failed"; }
            ;;
        "Zig")
            if [[ "$USE_NIX" == true ]]; then
                eval "$PKG_MANAGER zig" || { echo "Zig installation failed"; }
            else
                eval "tar xf zig-linux-x86_64-0.13.0.tar.xz"
                eval "echo 'export PATH="$HOME/zig-linux-x86_64-0.13.0:$PATH"' >> ~/.bashrc"
            fi
            ;;
        "Erlang")
            eval "$PKG_MANAGER erlang"
            ;;
        "Elixir")
            if [[ "$PKG_MANAGER" != "Nix" ]]; then
                if command_exists apt; then
                    # If ubuntu run:
                    sh <(curl -fsSL https://elixir-lang.org/install.sh)

                    # Ensure Elixir and Erlang paths are added to the system PATH
                    export ELIXIR_INSTALLS_DIR="$HOME/.elixir-install/installs"
                    export PATH="$ELIXIR_INSTALLS_DIR/otp/27.1.2/bin:$PATH"
                    export PATH="$ELIXIR_INSTALLS_DIR/elixir/1.18.2-otp-27/bin:$PATH"

                    # Persist PATH changes in ~/.bashrc and ~/.zshrc
                    echo "export PATH=\"$ELIXIR_INSTALLS_DIR/otp/27.1.2/bin:\$PATH\"" >> ~/.bashrc
                    echo "export PATH=\"$ELIXIR_INSTALLS_DIR/elixir/1.18.2-otp-27/bin:\$PATH\"" >> ~/.bashrc
                    echo "export PATH=\"$ELIXIR_INSTALLS_DIR/otp/27.1.2/bin:\$PATH\"" >> ~/.zshrc
                    echo "export PATH=\"$ELIXIR_INSTALLS_DIR/elixir/1.18.2-otp-27/bin:\$PATH\"" >> ~/.zshrc

                    # Reload shell to apply PATH changes
                    source ~/.bashrc || source ~/.zshrc

                    # Verify Elixir
                    if command_exists elixir && command_exists iex; then
                        success_message "Elixir installed successfully!"
                        elixir --version
                    else
                        error_message "Elixir installation failed!"
                        exit 1
                    fi
                fi
            else
                eval "$PKG_MANAGER elixir"
            fi
            ;;
    esac
    success_message "$lang Installed!"
done

install_vscode() {
    if command_exists apt; then
        info_message "Installing VSCode on Ubuntu/Debian..."
        
        # Install prerequisites
        sudo apt update && sudo apt install -y wget gpg

        # Import Microsoft's GPG key and add the repository
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

        # Install VSCode
        sudo apt update && sudo apt install -y code || { error_message "VSCode installation failed!"; exit 1; }

    elif command_exists dnf; then
        info_message "Installing VSCode on Fedora..."
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
        sudo dnf install -y code || { error_message "VSCode installation failed!"; exit 1; }

    elif command_exists pacman; then
        info_message "Installing VSCode on Arch Linux..."
        sudo pacman -Sy --noconfirm code || { error_message "VSCode installation failed!"; exit 1; }

    elif command_exists brew; then
        info_message "Installing VSCode on macOS..."
        brew install --cask visual-studio-code || { error_message "VSCode installation failed!"; exit 1; }

    else
        error_message "VSCode installation not supported on this system. Install it manually from https://code.visualstudio.com/"
    fi
}

# Install IDEs and Text Editors
echo "Selecting IDEs/Text Editors..."
editors=("Vscode" "IntelliJ" "Neovim" "Android Studio")
selected_editors=$(select_options "${editors[@]}")

info_message "Installing IDEs/Text Editors..."
for editor in $selected_editors; do
    info_message "Installing $editor..."
    case $editor in
        "Vscode")
            if [[ "$USE_NIX" == true ]]; then
                eval "$PKG_MANAGER vscode"
            else
                install_vscode
            fi
            ;;
        "IntelliJ")
            eval "$PKG_MANAGER intellij-idea-community"
            ;;
        "Neovim")
            eval "$PKG_MANAGER neovim"
            ;;
        "Android Studio")
            echo "Not supported yet"
            ;;
    esac

    success_message "$editor Installed!"
done

# Additional Developer Tools
echo "Selecting additional developer tools..."
dev_tools=("Docker" "Kubernetes CLI" "Terraform" "AWS CLI" "Azure CLI" "GCP SDK" "Github CLI")
selected_dev_tools=$(select_options "${dev_tools[@]}")

info_message "Installing additional developer tools..."
for tool in $selected_dev_tools; do
    info_message "Installing $tool..."
    case $tool in
        "Docker")
            eval "$PKG_MANAGER docker"
            ;;
        "Kubernetes CLI")
            eval "$PKG_MANAGER kubectl"
            ;;
        "Terraform")
            eval "$PKG_MANAGER terraform"
            ;;
        "AWS CLI")
            eval "$PKG_MANAGER awscli"
            ;;
        "Azure CLI")
            eval "$PKG_MANAGER awscli"
            ;;
        "GCP SDK")
            eval "$PKG_MANAGER awscli"
            ;;
        "Github CLI")
            eval "$PKG_MANAGER gh"
            ;;
    esac
    success_message "$editor Installed!"
done
 
success_message "Installation complete"
