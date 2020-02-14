# Resolve all dependencies that the repository requires to run.
#
# Links:
# - https://github.com/github/scripts-to-rule-them-all

# Set error action preference to stop if an error occurs.
$ErrorActionPreference = "Stop"

# Set URLs and file system paths.
$CondaRequirementsFilePath = Join-Path -Path "$RootDirectoryPath" -ChildPath "requirements.conda.txt"
$Miniconda3InstallationDirectoryPath = Join-Path -Path "$env:UserProfile" -ChildPath "Miniconda3"
$PipRequirementsFilePath = Join-Path -Path "$RootDirectoryPath" -ChildPath "requirements.txt"
$RootDirectoryPath = Split-Path -Path "$PSScriptRoot" -Parent
$TemporaryDirectoryPath = Join-Path -Path "$RootDirectoryPath" -ChildPath "temp"

# Set base URL of the Minconda3 installer..
$Miniconda3InstallerBaseUrl = "https://repo.anaconda.com/miniconda"

# Set the version of the Minconda3 distribution to use.
$Minconda3Version = Get-Content -Path (Join-Path -Path "$RootDirectoryPath" -ChildPath ".miniconda3-version")

# Set the name of the Miniconda3 environment.
$Minconda3EnvironmentName = Get-Content -Path (Join-Path -Path "$RootDirectoryPath" -ChildPath ".miniconda3-environment-name")

# Set the version of Python for the Miniconda3 environment.
$Minconda3EnvironmentPythonVersion = Get-Content -Path (Join-Path -Path "$RootDirectoryPath" -ChildPath ".miniconda3-environment-python-version")

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

# Download the Miniconda3 installer if it does not already exist.
if (!(Test-Path -Path "$Minconda3InstallerPath" -Type "Leaf"))
{
    Write-Output -InputObject "Downloading the Minconda3 installer..."
    Invoke-WebRequest -Uri "$Minconda3InstallerUrl" -OutFile "$Minconda3InstallerPath"
}
else
{
    Write-Output -InputObject "The Minconda3 installer already is already downloaded..."
}

# Run the Miniconda3 installer.
Write-Output -InputObject "Running the Minconda3 installer..."
Invoke-Expression -Command "${Minconda3InstallerPath} /S /InstallationType=JustMe /RegisterPython=0 /AddToPath=1 /NoRegistry=1 /D=${Miniconda3InstallationDirectoryPath}"

# Keep refreshing the `Path` environment variable until the `conda` command is
# found.
while (!(Get-Command "conda" -ErrorAction "SilentlyContinue"))
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

# Create the Miniconda3 environment.
Write-Output -InputObject "Creating the Miniconda3 environment..."
Invoke-Expression -Command "conda create -n ${Minconda3EnvironmentName} python=${Minconda3EnvironmentPythonVersion} -y"

# Set up the conda hook.
Write-Output -InputObject "Setting up the conda hook..."
(& "conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression

# Activate the Miniconda3 environment.
Write-Output -InputObject "Activating the Miniconda3 environment..."
Invoke-Expression -Command "conda activate ${Minconda3EnvironmentName}"

# Install conda requirements in the Miniconda3 environment.
Write-Output -InputObject "Installing conda requirements in the Miniconda3 environment..."
foreach ($CondaRequirement in Get-Content -Path "$CondaRequirementsFilePath")
{
    Invoke-Expression -Command "conda install --yes '${CondaRequirement}'"
}

# Install pip requirements in the Miniconda3 environment.
Write-Output -InputObject "Installing pip requirements in the Miniconda3 environment..."
Invoke-Expression -Command "pip install --requirement '${PipRequirementsFilePath}'"
