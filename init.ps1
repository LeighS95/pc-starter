# FUNCTIONS

function Message {
    param (
        [string]$msg,
        [string]$color = "White"
    )
    Write-Host "`n$msg" -ForegroundColor $color
}

function Prompt-Message {
    param ([string]$msg)
    Write-Host "`n$msg"
}

function Success-Message {
    param ([string]$msg)
    Message -msg $msg -color "Green"
}

function Info-Message {
    param ([string]$msg)
    Message -msg $msg -color "Cyan"
}

function Warn-Message {
    param ([string]$msg)
    Message -msg $msg -color "Yellow"
}

function Processing-Message {
    param ([string]$msg)
    Message -msg $msg -color "Blue"
}

function Error-Message {
    param ([string]$msg)
    Message -msg $msg -color "Red"
}

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$Command
    )
    return bool(Get-Command $command -ErrorAction SilentlyContinue)
}

# Function to select a package manager
function Select-PackageManager {
    $packageManagers = @("Scoop", "Chocolatey")
    Prompt-Message "Select a package manager:"
    for ($i = 0; $i -lt $packageManagers.Length; $i++) {
        Prompt-Message "$($i+1)) $($packageManagers[$i])"
    }
    $selection = Read-Host "Enter the number of your choice"
    return $packageManagers[$selection - 1]
}

# Function to display a menu and capture user choices
function Select-Options {
    param (
        [string]$Title,
        [string[]]$Options
    )
    Prompt-Message "`n$Title"
    for ($i = 0; $i -lt $Options.Length; $i++) {
        Prompt-Message "$($i+1)) $($Options[$i])"
    }
    $selection = Read-Host "Enter numbers separated by spaces (e.g., 1 3 5)"
    return ($selection -split " ") | ForEach-Object { $_ -as [int] } | Where-Object { $_ -gt 0 -and $_ -le $Options.Length } | ForEach-Object { $Options[$_ - 1] }
}
