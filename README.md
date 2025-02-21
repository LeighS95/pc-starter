# PC Starter

A quick start script for bash or windows powershell to quickly setup a new pc quickly and easily.

It currently offers setup of the following:

| OS    | Package Managers |Browsers |Git|
|-------|------------------|---------|---|
| Mac   | Homebrew & Nix   |Chrome   |Yes|
|Linux  | Default & Nix    |Chrome   |Yes|
|Windows| Scoop & Choco    |Chrome   |Yes|

- #### Tools
    - fzf
    - jq
    - tmux
    - fselect (mac only)
- #### Emulators
    - Ghostty
    - Kitty
- #### Programming Languages
    - Python
    - NodeJS
    - Rust
    - Golang
    - Ruby
    - Java
    - Kotlin
    - C
    - C++
    - Zig
    - Erlang
    - Elixir
- #### Text Editors
    - VsCode
    - Neovim
    - InteliJ
    - Android Studio
- #### DevTools
    - Docker
    - Kubectl
    - Terraform
    - AWS Cli
    - Azure Cli
    - GCloud SDK
    - Github Cli

## To run locally

### Prerequisites
 - git

Run:
```
git clone "https://github.com/LeighS95/pc-starter"
```

Then cd to localation of repo and then run:

```
./setup.sh
```

## To run Remotely

### Windows (Powershell)

```powershell
powershell -ExecutionPolicy Bypass -Command "& {Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/LeighS95/pc-starter/main/setup.ps1')}"
```

OR

```powershell
curl -sL "https://raw.githubusercontent.com/LeighS95/pc-starter/main/setup.ps1" | powershell -ExecutionPolicy Bypass -File -
```

### Mac & Linux (Bash)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/LeighS95/pc-starter/main/setup.sh)
```

Or

```bash
wget -qO- https://raw.githubusercontent.com/LeighS95/pc-starter/main/setup.sh | bash
```