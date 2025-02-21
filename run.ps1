# PowerShell Script for Developer Setup

# run.ps1 - Handles Both Local and Remote Cases

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Error-Message "Please run this script as Administrator."
    exit
}

# Define local file path and remote URL
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$localUtilsPath = "$scriptPath\init.ps1"
$remoteUtilsUrl = "https://raw.githubusercontent.com/LeighS95/pc-starter/main/init.ps1"

# Check if init.ps1 exists locally
if (Test-Path $localUtilsPath) {
    Info-Message "Loading local init.ps1..."
    . $localUtilsPath
} else {
    Processing-Message "Downloading init.ps1 from remote..."
    try {
        $utilsContent = Invoke-WebRequest -Uri $remoteUtilsUrl -UseBasicParsing
        Invoke-Expression $utilsContent.Content
    } catch {
        Error-Message "Failed to download init.ps1. Please check your internet connection."
        exit 1
    }
}

# Prompt user to select a package manager
$packageManager = Select-PackageManager

# Install selected package manager
switch ($packageManager) {
    "Scoop" {
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            Processing-Message "Installing Scoop..."
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
            Success-Message "Scoop Installed"
        }
        $PKG_CMD = "scoop install"
    }
    "Chocolatey" {
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Processing-Message "Installing Chocolatey..."

            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

            $env:Path += ";$env:ALLUSERSPROFILE\chocolatey\bin"

            Success-Message "Choco Installed"
        }
        $PKG_CMD = "choco install -y"
    }
}

Info-Message "Using $packageManager"

# Check if git is installed
if (-not (Command-Exists git)) {
    Processing-Message "Installing Git..."

    if ($packageManager -eq "Scoop") {
        Invoke-Expression "scoop install git"
    }
    elseif ($packageManager -eq "Chocolatey") {
        Invoke-Expression "choco install -y git"
    }
    else {
        Error-Message "Unsupported Package Manager. Please install git manually"
        exit 1
    }

    Success-Message "Git Installed!"
} else {
    Info-Message "Git is already installed."
}

# Install chrome
Processing-Message "Installing chrome..."

if ($packageManager == "Scoop") {
    Invoke-Expression "scoop bucket add extras"
    Invoke-Expression "scoop install extras/googlechrome"
}
elseif ($packageManager == "Chocolatey") {
    Invoke-Expression "choco install googlechrome"
}
else {
    $LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe"; (new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); & "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)
}

Success-Message "Chrome installed."

# Install essential software
Info-Message "Installing essentials..."
$software = @("curl", "wget", "fzf", "cygwin")
foreach ($pkg in $software) {
    Processing-Message "Installing $pkg..."
    if ("$packageManager" == "scoop") {;
        Invoke-Expression "scoop bucket add main"
        Invoke-Expression "$PKG_CMD main/curl"
        Invoke-Expression "$PKG_CMD main/wget"
        Invoke-Expression "$PKG_CMD main/fzf"
        Invoke-Expression "$PKG_CMD main/cygwin"
        Invoke-Expression "scoop bucket add extras"
        Invoke-Expression "$PKG_CMD extras/psfzf"
    }
    else {
        Invoke-Expression "$PKG_CMD $pkg"
    }
    Success-Message "$pkg Installed!"
}


# Install Programming Languages
$languages = @("Python", "Node.js", "Rust", "Ruby", "Golang", "Elixir", "C", "Zig")
$selectedLanguages = Select-Options -Title "Select Programming Languages" -Options $languages

foreach ($lang in $selectedLanguages) {
    Processing-Message "Installing $pkg..."
    switch ($lang) {
        "Zig" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/zig"
            } else {
                Invoke-Expression "$PKG_CMD zig"
            }
        }
        "Elixir" {
            # curl.exe -fsSO https://elixir-lang.org/install.bat .\install.bat elixir@1.18.2 otp@27.1.2 $installs_dir = "$env:USERPROFILE\.elixir-install\installs" $env:PATH = "$installs_dir\otp\27.1.2\bin;$env:PATH" $env:PATH = "$installs_dir\elixir\1.18.2-otp-27\bin;$env:PATH" iex.bat
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/elixir"
            } else {
                Invoke-Expression "$PKG_CMD elixir"
            }
        }
        "Python" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/python"
            } else {
                Invoke-Expression "$PKG_CMD main/python"
            }
        }
        "Node.js" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/nvm"
                Invoke-Expression "nvm install --lts"
            } else {
                Invoke-Expression "$PKG_CMD nvm"
                Invoke-Expression "nvm install --lts"
            }
        }
        "Rust" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/rustup"
                Invoke-Expression "rustup update"
            } else {
                Invoke-Expression "$PKG_CMD rustup.install"
                Invoke-Expression "rustup update"
            }
        }
        "C" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/gcc"
            } else {
                Invoke-Expression "$PKG_CMD llvm"
            }
        }
        "Golang" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/go"
            } else {
                Invoke-Expression "$PKG_CMD go"
            }
        }
        "Ruby" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/ruby"
            } else {
                Invoke-Expression "$PKG_CMD ruby"
            }
        }
    }

    Success-Message "$pkg Installed!"
}

# Install IDEs and Text Editors
$editors = @("Vscode", "Neovim", "Android Studio")
$selectedEditors = Select-Options -Title "Select IDEs/Text Editors to Install" -Options $editors

foreach ($editor in $selectedEditors) {
    Processing-Message "Installing $editor..."
    switch ($editor) {
        "Vscode" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add extras"
                Invoke-Expression "$PKG_CMD extras/vscode"
            } else {
                Invoke-Expression "$PKG_CMD vscode"
            }
        }
        "Neovim" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/neovim"
            } else {
                Invoke-Expression "$PKG_CMD neovim"
            }
        }
        "Android Studio" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add extras"
                Invoke-Expression "$PKG_CMD extras/android-studio"
            } else {
                Invoke-Expression "$PKG_CMD androidstudio"
            }
        }
    }
    Success-Message "$editor Installed!"
}

# Additional Developer Tools
$devTools = @("Docker", "Kubectl", "Terraform", "AWS CLI", "Azure CLI", "GCP SDK", "Github CLI")
$selectedDevTools = Select-Options -Title "Select Additional Developer Tools to Install" -Options $devTools

foreach ($tool in $selectedDevTools) {
    Processing-Message "Installing $tool..."
    switch ($tool) {
        "Docker" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/docker"
            } else {
                Invoke-Expression "$PKG_CMD docker-cli"
            }
        }
        "Kubectl" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/kubectl"
            } else {
                Invoke-Expression "$PKG_CMD kubernetes-cli"
            }
        }
        "Terraform" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/terraform"
            } else {
                Invoke-Expression "$PKG_CMD terraform"
            }
        }
        "AWS CLI" {
            if ($PackageManager == "scoop") {
                Write-Host "Not Found"
            } else {
                Invoke-Expression "$PKG_CMD awscli"
            }
        }
        "Azure CLI" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/azure-cli"
            } else {
                Invoke-Expression "$PKG_CMD azure-cli"
            }
        }
        "GCP SDK" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add extras"
                Invoke-Expression "$PKG_CMD extras/gcloud"
            } else {
                Invoke-Expression "$PKG_CMD gcloudsdk"
            }
        }
        "Github CLI" {
            if ($PackageManager == "scoop") {
                Invoke-Expression "scoop bucket add main"
                Invoke-Expression "$PKG_CMD main/gh"
            } else {
                Invoke-Expression "$PKG_CMD gh"
            }
        }
    }

    Success-Message "$tool Installed!"
}

Info-Message "Installations complete"