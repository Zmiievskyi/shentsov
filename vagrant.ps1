
Write-Host "==================================="
Write-Host "Stealing Yulia's photos Script"
Write-Host "==================================="
Write-Host ""

# Elevate script to run as Administrator if not already running as one
$adminCheck = [System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $adminCheck.IsInRole([System.Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Restarting script with elevated privileges..."
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Check for Chocolatey and install if missing
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force;
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install Chocolatey."
        pause
        exit 1
    }
}
else {
    Write-Host "Chocolatey already installed."
}
# Install Git if not installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git not found. Installing Git..."
    choco install git -y
    if (-not (Get-Command Git -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install Git."
        pause
        exit 1
    }
}
else {
    Write-Host "Git is already installed."
}


# Install VirtualBox if not installed
if (-not (Get-Command virtualbox -ErrorAction SilentlyContinue)) {
    Write-Host "VirtualBox not found. Installing VirtualBox..."
    choco install virtualbox -y
    if (-not (Get-Command virtualbox -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install VirtualBox."
        pause
        exit 1
    }
}
else {
    Write-Host "VirtualBox is already installed."
}

# Install Vagrant if not installed
if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
    Write-Host "Vagrant not found. Installing Vagrant..."
    choco install vagrant -y
    if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
        Write-Host "Failed to install Vagrant."
        pause
        exit 1
    }
}
else {
    Write-Host "Vagrant is already installed."
}

Write-Host "Installation complete!"

# Create and initialize Vagrant environment
$VagrantfileContent = @'
Vagrant.configure("2") do |config|
  config.vm.box = "gusztavvargadr/windows-10"
  config.vm.box_version = "2202.0.2409"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "8096"
    vb.cpus = 4
    vb.gui = true  # Show VM window
  end
  config.vm.synced_folder "C:/win10", "/host_shared"
  config.vm.provision "shell", privileged: true, powershell_args: "-ExecutionPolicy Bypass", inline: <<-SHELL
      $LightBurnInstaller = "C:/host_shared/LightBurn-v1.7.07.exe"
      Start-Process $LightBurnInstaller -ArgumentList "/silent /install" -Wait
      Write-Host "LightBurnSoftware installation complete!"
  SHELL

end
'@

# Create directory for Vagrant setup
$VagrantPath = "C:\win10"
if (!(Test-Path -Path $VagrantPath)) {
    New-Item -ItemType Directory -Path $VagrantPath | Out-Null
}
Set-Location -Path $VagrantPath

# Write the content to Vagrantfile
$VagrantfileContent | Out-File -FilePath "Vagrantfile" -Encoding utf8

Write-Host "Vagrantfile has been created successfully!"

# Initialize and start Vagrant
vagrant up

Write-Host "Thank you for all photos are stolen!"
pause
