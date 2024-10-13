# Setup-DevEnvironment.ps1

# Exit immediately if a command exits with a non-zero status
$ErrorActionPreference = "Stop"

# Function to check if the script is running as Administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check if a command exists
function Command-Exists {
    param (
        [string]$CommandName
    )
    return Get-Command $CommandName -ErrorAction SilentlyContinue -CommandType Application, Alias, Function, Cmdlet
}

# Function to install Chocolatey
function Install-Chocolatey {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Function to install a Chocolatey package if not already installed
function Install-PackageIfMissing {
    param (
        [string]$PackageName,
        [string]$PackageParams = ""
    )
    if (-not (choco list --local-only | Select-String -Pattern "^$PackageName\|")) {
        Write-Output "Installing $PackageName..."
        choco install $PackageName -y $PackageParams
    }
    else {
        Write-Output "$PackageName is already installed."
    }
}

# Function to pause and prompt the user
function Pause-ForUser {
    Write-Output "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Ensure the script is running as Administrator
if (-not (Test-Administrator)) {
    Write-Output "This script must be run as an Administrator. Please right-click the script and select 'Run as Administrator'."
    Pause-ForUser
    exit
}

# Install Chocolatey if not installed
if (-not (Command-Exists choco)) {
    Install-Chocolatey
} else {
    Write-Output "Chocolatey is already installed."
}

# Refresh environment variables
refreshenv

# Update Chocolatey to the latest version
Write-Output "Updating Chocolatey to the latest version..."
choco upgrade chocolatey -y

# Install Git with Unix tools on PATH
Install-PackageIfMissing -PackageName "git" -PackageParams '--params "/GitAndUnixToolsOnPath"'

# Install Node.js LTS
Install-PackageIfMissing -PackageName "nodejs-lts"

# Install Python
Install-PackageIfMissing -PackageName "python"

# Install Docker Desktop
Install-PackageIfMissing -PackageName "docker-desktop"

# Optionally install Visual Studio Code
$installVscode = Read-Host "Do you want to install Visual Studio Code? (Y/N)"
if ($installVscode -match '^[Yy]$') {
    Install-PackageIfMissing -PackageName "vscode"
} else {
    Write-Output "Skipping installation of Visual Studio Code."
}

# Pause before proceeding
Pause-ForUser

# Clone the GitHub repository
$cloneRepo = Read-Host "Do you want to clone the project repository from GitHub? (Y/N)"
if ($cloneRepo -match '^[Yy]$') {
    $defaultRepoUrl = "https://github.com/delphius80/todo-react-django.git"
    $repoUrl = Read-Host "Enter the repository URL (Press Enter to use default: $defaultRepoUrl)"
    if ([string]::IsNullOrWhiteSpace($repoUrl)) {
        $repoUrl = $defaultRepoUrl
    }
    Write-Output "Cloning repository from $repoUrl..."
    git clone $repoUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Output "Failed to clone repository. Please check the URL and your internet connection."
        Pause-ForUser
        exit
    }
} else {
    Write-Output "Skipping repository cloning."
}

# Pause before proceeding
Pause-ForUser

# Setup Python virtual environment and install dependencies
if ($cloneRepo -match '^[Yy]$') {
    # Extract repository folder name from URL
    $repoName = ($repoUrl.Split('/') | Select-Object -Last 1) -replace '\.git$', ''
    $backendPath = Join-Path -Path (Get-Location) -ChildPath "$repoName\backend"
    $requirementsPath = Join-Path -Path $backendPath -ChildPath "requirements.txt"

    if (Test-Path $requirementsPath) {
        Write-Output "Setting up Python virtual environment in $backendPath..."
        cd $backendPath

        # Create virtual environment if it doesn't exist
        if (-not (Test-Path "venv")) {
            Write-Output "Creating virtual environment..."
            python -m venv venv
            if ($LASTEXITCODE -ne 0) {
                Write-Output "Failed to create virtual environment."
                Pause-ForUser
                exit
            }
        } else {
            Write-Output "Virtual environment already exists."
        }

        # Activate virtual environment
        Write-Output "Activating virtual environment..."
        & "$backendPath\venv\Scripts\Activate.ps1"

        # Upgrade pip
        Write-Output "Upgrading pip..."
        python -m pip install --upgrade pip

        # Install Python dependencies
        Write-Output "Installing Python dependencies from requirements.txt..."
        python -m pip install -r requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Output "Failed to install Python dependencies."
            Pause-ForUser
            exit
        } else {
            Write-Output "Python dependencies installed successfully."
        }

        # Deactivate virtual environment
        Write-Output "Deactivating virtual environment..."
        deactivate

        # Return to original directory
        cd (Get-Location).Path -replace "\\backend$",""
    } else {
        Write-Output "requirements.txt not found in $backendPath. Skipping Python dependencies installation."
    }

    # Setup Frontend (React)
    $frontendPath = Join-Path -Path (Get-Location) -ChildPath "$repoName\frontend"
    $packageJsonPath = Join-Path -Path $frontendPath -ChildPath "package.json"

    if (Test-Path $packageJsonPath) {
        Write-Output "Setting up Frontend in $frontendPath..."
        cd $frontendPath

        # Install Node.js dependencies
        if (-not (Test-Path "node_modules")) {
            Write-Output "Installing Node.js dependencies..."
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Output "Failed to install Node.js dependencies."
                Pause-ForUser
                exit
            } else {
                Write-Output "Node.js dependencies installed successfully."
            }
        } else {
            Write-Output "Node.js dependencies already installed."
        }

        # Build React application
        Write-Output "Building React application..."
        npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Output "Failed to build React application."
            Pause-ForUser
            exit
        } else {
            Write-Output "React application built successfully."
        }

        # Return to original directory
        cd (Get-Location).Path -replace "\\frontend$",""
    } else {
        Write-Output "package.json not found in $frontendPath. Skipping Frontend setup."
    }
} else {
    Write-Output "Repository was not cloned. Skipping environment setup for the project."
}

# Optionally install Python packages from requirements.txt in the current directory
$installCurrentPackages = Read-Host "Do you want to install Python packages from a requirements.txt in the current directory? (Y/N)"
if ($installCurrentPackages -match '^[Yy]$') {
    if (Test-Path ".\requirements.txt") {
        Write-Output "Installing Python packages from requirements.txt in the current directory..."
        python -m pip install --upgrade pip
        python -m pip install -r .\requirements.txt
        if ($LASTEXITCODE -ne 0) {
            Write-Output "Failed to install Python packages."
            Pause-ForUser
            exit
        } else {
            Write-Output "Python packages installed successfully."
        }
    } else {
        Write-Output "requirements.txt not found in the current directory."
    }
} else {
    Write-Output "Skipping installation of Python packages from the current directory."
}

# Final message
Write-Output "`nDevelopment environment setup is complete."
Write-Output "If prompted, please restart your computer to finalize installations."
Pause-ForUser
