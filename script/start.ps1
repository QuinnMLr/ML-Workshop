# Start required processes for the repository locally.
#
# Links:
# - https://github.com/github/scripts-to-rule-them-all

# Set error action preference to stop if an error occurs.
$ErrorActionPreference = "Stop"

# Ensure the `Path` environment variable is up to date.
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

# Set file system paths.
$RootDirectoryPath = Split-Path -Path "$PSScriptRoot" -Parent
$NotebookDirectoryPath = Join-Path -Path "$RootDirectoryPath" -ChildPath "notebook"

# Set the name of the Miniconda3 environment.
$Minconda3EnvironmentName = Get-Content -Path (Join-Path -Path "$RootDirectoryPath" -ChildPath ".miniconda3-environment-name")

# Create the repository's notebook directory if it does not alreay exist.
if (!(Test-Path -Path "$NotebookDirectoryPath" -PathType  "Container"))
{
    Write-Output -InputObject "Creating the repository's notebook directory..."
    New-Item -Path "$NotebookDirectoryPath" -ItemType "Directory" | Out-Null
}
else
{
    Write-Output -InputObject "The repository's notebook directory already exists."
}

# Set up the conda hook.
Write-Output -InputObject "Setting up the conda hook..."
(& "conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression

# Activate the Miniconda3 environment.
Write-Output -InputObject "Activating the Conda Virtual environment..."
Invoke-Expression -Command "conda activate ${Minconda3EnvironmentName}"

# Start the Jupyter Notebook server.
Write-Output -InputObject "Starting the Jupyter Notebook server..."
Invoke-Expression -Command "jupyter notebook --notebook-dir='${NotebookDirectoryPath}'"
