$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
$RootDirectoryPath = Split-Path -Path "$PSScriptRoot" -Parent
$NotebookDirectoryPath = Join-Path -Path "$RootDirectoryPath" -ChildPath "notebook"

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

Write-Output -InputObject "Initializing Conda for PowerShell..."
(& "conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression

Write-Output -InputObject "Activating Virtual Environment..."
Invoke-Expression -Command "conda activate nwmlworkshop"

Write-Output -InputObject "Starting jupyter notebook server..."
Invoke-Expression -Command "jupyter notebook --notebook-dir='$NotebookDirectoryPath'"
