# PC Starter

A quick start script for bash or windows powershell to quickly setup a new pc quickly and easily.

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

### Prerequisites
 - curl or wget

### Windows (Powershell)

```powershell
powershell -ExecutionPolicy Bypass -Command "& {Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/LeighS95/pc-starter/main/run.ps1')}"
```

OR

```powershell
curl -sL "https://raw.githubusercontent.com/LeighS95/pc-starter/main/run.ps1" | powershell -ExecutionPolicy Bypass -File -
```

### Mac & Linux (Bash)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/LeighS95/pc-starter/main/run.sh)
```

Or

```bash
wget -qO- https://raw.githubusercontent.com/LeighS95/pc-starter/main/run.sh | bash
```

## Currently Supported

It currently offers setup of the following:

|Package Managers    | Windows | Mac | Linux |
|--------------------|---------|-----|-------|
|Scoop               | ✅      | ❌ | ❌   |
|Choco               | ✅      | ❌ | ❌   |
|Winget              | ❌      | ❌ | ❌   |
|Homebrew            | ❌      | ✅ | ❌   |
|Nix                 | ❌      | ✅ | ✅   |
|Linux Distro default| ❌      | ❌ | ✅   |

|Browsers|Windows|Mac|Linux|
|--------|-------|---|-----|
|Chrome  | ✅   | ✅| ✅  |


|Language|Windows|Mac |Linux|
|--------|-------|----|-----|
|Python  | ✅   | ✅ | ✅ |
|Nodejs  | ✅   | ✅ | ✅ |
|Rust    | ✅   | ✅ | ✅ |
|Golang  | ✅   | ✅ | ✅ |
|Ruby    | ✅   | ✅ | ✅ |
|Java    | ❌   | ✅ | ✅ |
|Kotlin  | ❌   | ✅ | ✅ |
|C       | ✅   | ✅ | ✅ |
|C++     | ✅   | ✅ | ✅ |
|Zig     | ✅   | ✅ | ✅ |
|Elixir  | ✅   | ✅ | ✅ |


|Tool   |Windows|Mac|Linux|
|-------|-------|---|-----|
|fzf    | ✅   |✅ |✅  |
|jq     | ❌   |✅ |✅  |
|tmux   | ❌   |✅ |✅  |
|fselect| ❌   |✅ |❌  |
|curl   | ✅   |✅ |✅  |
|wget   | ✅   |✅ |✅  |
|cygwin | ✅   |❌ |❌  |
|psfzf  | ✅   |❌ |❌  |

|Emulators |Windows|Mac|Linux|
|----------|-------|---|-----|
|Ghostty   | ❌   |✅ |✅  |
|Kitty     | ❌   |✅ |✅  |

|Text Editors  |Windows|Mac            |Linux          |
|--------------|-------|---------------|---------------|
|VsCode        | ✅   | ✅            | ✅            |
|Neovim        | ✅   | ✅            | ✅            |
|Android Studio| ✅   | ✅ (Nix only) | ✅ (Nix only) |

|Dev Tools |Windows|Mac           |Linux         |
|----------|-------|--------------|--------------|
|Docker    | ✅   | ✅(nix only) | ✅(nix only) |
|Kubctl    | ✅   | ✅           | ✅(nix only) |
|Terraform | ✅   | ✅           | ✅(nix only) |
|Aws Cli   | ✅   | ✅           | ✅           |
|Azure Cli | ✅   | ✅           | ✅           |
|Gcloud SDK| ✅   | ✅           | ✅           |
|Github Cli| ✅   | ✅           | ✅           |