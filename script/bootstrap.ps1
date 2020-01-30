# Set error action preference to stop if an error occurs.
$ErrorActionPreference = "Stop"

# Set URLs and file system paths.
$Miniconda3InstallationDirectoryPath = Join-Path -Path "$env:UserProfile" -ChildPath "Miniconda3"
$RootDirectoryPath = Split-Path -Path "$PSScriptRoot" -Parent
$TemporaryDirectoryPath = Join-Path -Path "$RootDirectoryPath" -ChildPath "temp"

# Set base URL of the Minconda3 installer..
$Miniconda3InstallerBaseUrl = "https://repo.anaconda.com/miniconda"

# Set the version of the Minconda3 distribution to use.
$Minconda3Version = "4.7.12.1"

# Set architecture-specific variables.
if ([System.Environment]::Is64BitOperatingSystem)
{
    $Minconda3InstallerName = "Miniconda3-${Minconda3Version}-Windows-x86_64.exe"
    $Minconda3InstallerUrl = "${Miniconda3InstallerBaseUrl}/${Minconda3InstallerName}"
}
else
{
    $Minconda3InstallerName = "Miniconda3-${Minconda3Version}-Windows-x86.exe"
    $Minconda3InstallerUrl = "${Miniconda3InstallerBaseUrl}/${Minconda3InstallerName}"
}

# Set the path of the Minconda3 installer.
$Minconda3InstallerPath = Join-Path -Path "$TemporaryDirectoryPath" -ChildPath "$Minconda3InstallerName"

# Create the repository's temporary directory if it does not alreay exist.
if (!(Test-Path -Path "$TemporaryDirectoryPath" -PathType  "Container"))
{
    Write-Output -InputObject "Creating the repository's temporary directory..."
    New-Item -Path "$TemporaryDirectoryPath" -ItemType "Directory" | Out-Null
}
else
{
    Write-Output -InputObject "The repository's temporary directory already exists."
}

if (!(Test-Path -Path "$Minconda3InstallerPath" -Type "Leaf"))
{
    Write-Output -InputObject "Downloading the Minconda3 installer..."
    Invoke-WebRequest -Uri "$Minconda3InstallerUrl" -OutFile "$Minconda3InstallerPath"
}
else
{
    Write-Output -InputObject "The Minconda3 installer already is already downloaded..."
}

Write-Output -InputObject "Running the Minconda3 installer..."
Invoke-Expression -Command "${Minconda3InstallerPath} /S /InstallationType=JustMe /RegisterPython=0 /AddToPath=1 /NoRegistry=1 /D=${Miniconda3InstallationDirectoryPath}"

while (!(Get-Command "conda" -ErrorAction "SilentlyContinue"))
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

Write-Output -InputObject "Creating Conda virtual environment..."
Invoke-Expression -Command "conda create -n nwmlworkshop python=3.6 -y"

Write-Output -InputObject "Initializing Conda for PowerShell..."
(& "conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression

Write-Output -InputObject "Activating the Conda virtual environment..."
Invoke-Expression -Command "conda activate nwmlworkshop"

Write-Output -InputObject "Installing dependencies..."
Invoke-Expression -Command "conda install jupyter -y"
Invoke-Expression -Command "conda config --append channels conda-forge"
Invoke-Expression -Command "conda install -c h2oai h2o -y"
Invoke-Expression -Command "pip install h2o"
