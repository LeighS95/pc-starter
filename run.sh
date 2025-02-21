#!/bin/bash

# Ensure script is executed with proper permissions
if [[ $(id -u) -eq 0 ]]; then
    echo "Running as root. This script should be run as a normal user with sudo where necessary."
    exit 1
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
    if ! command -v curl 2>&1 >/dev/null; then
        curl -fsSL "$REMOTE_UTILS" -o /tmp/init.sh || { echo "Failed to download init.sh"; exit 1; }
    elif ! command -v wget 2>&1 >/dev/null; then
        wget -q "$REMOTE_UTILS" -O /tmp/init.sh || { echo "Failed to download init.sh"; exit 1; }
    else
        echo "Neither curl nor wget is available. Cannot download init.sh."
        exit 1
    fi
    source /tmp/init.sh
fi

info_message "Detecting OS and Architecture..."
detect_OS
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
                if ! commend_exists nix; then
                    info_message "Installing Nix package manager..."
                    curl -L https://nixos.org/nix/install | sh
                fi
                break;;
            "Homebrew")
                if ! commend_exists brew; then
                    info_message "Installing Homebrew..."
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
                if ! commend_exists nix; then
                    info_message "Installing Nix package manager..."
                    curl -L https://nixos.org/nix/install | sh
                fi
                break;;
            "Default ($DISTRO)")
                break;;
            *) error_message "Invalid option. Please select 1 or 2.";;
        esac
    done
fi

# Set package manager command
if [[ "$USE_NIX" == true ]]; then
    PKG_MANAGER="nix-env -i"
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

# Install Chrome
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

# Check for git and then Install git
if ! command_exists git; then
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

info_message "Installing tools..."
for tool in $tools; do
    info_message "Installing $tool..."
    eval "$PKG_MANAGER $tool" || { error_message "$tool installation failed"; exit 1; }
    success_message "Installed $tool!"
done

# Intall terminals
echo "Selecting terminal emulators"
terminals=("Ghostty" "Kitty")
selected_terminals=$(select_options "${terminals[@]}")

info_message "Installing terminals..."
for term in $selected_terminals; do
    case $term in
        "Ghostty")
            if [[ "$PACKAGE_MANAGER" == "homebrew" ]]; then
                eval "$PKG_MANAGER --cask ghostty" || { error_message "ghostty installation failed"; exit 1; }
            else
                eval "$PKG_MANAGER ghostty" || { error_message "ghostty installation failed"; exit 1; }
            fi
            success_message "Ghostty Installed!"
            ;;
        "Kitty")
            eval "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"|| { error_message "Kitty installation failed"; exit 1; }

            success_message "Kitty Installed"
            ;;
    esac
done

# Install programming languages
echo "Selecting programming languages"
langs=("Python" "Node" "Rust" "Golang" "Ruby" "Java" "Kotlin" "C" "Cpp" "Zig" "Elixir")
selected_langs=$(select_options "${langs[@]}")

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
            if command -v apt &>/dev/null; then
                eval "$PKG_MANAGER ruby-full"
            else
                eval "$PKG_MANAGER ruby"
            ;;
        "PHP")
            eval "$PKG_MANAGER php"
            ;;
        "Java")
            if ! command_exists sdkman; then
                echo "Installing sdkman..."
                eval "curl -s "https://get.sdkman.io" | bash"
                eval "source "$HOME/.sdkman/bin/sdkman-init.sh""
                eval "sdk version"
            fi
            eval "sdk install java" || { echo "Java installation failed"; }
            ;;
        "Kotlin")
            if ! command_exists sdkman; then
                echo "Installing sdkman..."
                eval "curl -s "https://get.sdkman.io" | bash"
                eval "source "$HOME/.sdkman/bin/sdkman-init.sh""
                eval "sdk version"
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
            # If ubuntu run:
            # eval "curl -fsSO https://elixir-lang.org/install.sh sh install.sh elixir@1.18.2 otp@27.1.2 installs_dir=$HOME/.elixir-install/installs export PATH=$installs_dir/otp/27.1.2/bin:$PATH export PATH=$installs_dir/elixir/1.18.2-otp-27/bin:$PATH iex"
            # Else run
            eval "$PKG_MANAGER elixir"
            ;;
    esac
    success_message "$lang Installed!"
done

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
                eval "$PKG_MANAGER code.deb"
                eval "echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections"
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
