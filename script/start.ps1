$RootDirectoryPath = Split-Path -Path "$PSScriptRoot" -Parent
$NotebookDirectoryPath = Join-Path -Path "$RootDirectoryPath" -ChildPath "notebook"

Write-Output -InputObject "Initializing Conda for PowerShell..."
(& "C:\Users\milleq2\Miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Invoke-Expression

Write-Output -InputObject "Activating Virtual Environment..."
Invoke-Expression -Command "conda activate nwmlworkshop"

Write-Output -InputObject "Starting jupyter notebook server..."
Invoke-Expression -Command "jupyter notebook --notebook-dir='$NotebookDirectoryPath'"
