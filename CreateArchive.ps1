$ScriptPath = split-path -parent $MyInvocation.MyCommand.Definition
Write-Output "Path of the script : $ScriptPath"

# Convert commit message to a single line if multiline
$singleLineStrVal = "$Env:COMMIT_MESSAGE" -replace "`r`n", " " -replace "`n", " "
if($singleLineStrVal -match '#GITBUILD')
{
      Write-Host 'Commit message matched with "#GITBUILD"'
}

try {
      Import-Module 7Zip4PowerShell
} catch {
      Write-Host 'Installing 7Zip PowerShell module'
      Install-Module 7Zip4PowerShell -Force -Verbose -MinimumVersion "2.4"
}

try {
      dotnet build --verbosity=detailed --self-contained --nologo --configuration=Release --arch=x64 "$ScriptPath/UnityLauncherPro/UnityLauncherPro.csproj"
      Write-Host 'Finished building project.'

      Write-Host 'Compressing executable into archive...'
      $OutputFilename = "UnityLauncherPro.zip"
      $OutputPath = "$ScriptPath/.build/$OutputFilename"
      if (Test-Path "$OutputPath" -PathType Leaf) {
            Remove-Item -Force -Path "$OutputPath"
      }
      Compress-7Zip -Path "$ScriptPath/UnityLauncherPro/bin/Release/net8.0-windows/win-x64" -ArchiveFilename "$OutputFilename" -OutputPath "$OutputPath"

      Write-Host "Archive now available here: '$ScriptPath/UnityLauncherPro.zip'"
} catch {
      Write-Error 'Failed to update archive.'
}
