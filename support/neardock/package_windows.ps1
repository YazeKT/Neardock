param([ValidateSet('x64','arm64')][string]$Architecture = 'x64')
$ErrorActionPreference = 'Stop'
$rootPath = (Resolve-Path "$PSScriptRoot/../..").Path
$bundlePath = Join-Path $rootPath "app/build/windows/$Architecture/runner/Release"
$outputPath = Join-Path $rootPath 'dist'
New-Item -ItemType Directory -Force -Path $outputPath | Out-Null
if (!(Test-Path "$bundlePath/neardock.exe")) { throw 'Build the requested Windows architecture first.' }
# The installer uses app-data settings. The separate portable copy uses local settings.
if ($Architecture -eq 'x64') {
    Copy-Item "$rootPath/app/assets/packaging/logo.ico" "$bundlePath/logo.ico"
    Copy-Item -Path @("$rootPath/LICENSE", "$rootPath/NOTICE.md", "$rootPath/THIRD_PARTY_NOTICES.md", "$rootPath/BRAND_ASSETS.md") -Destination $bundlePath
    $compilerPath = (Get-Command ISCC.exe -ErrorAction SilentlyContinue).Source
    if (!$compilerPath) {
        $compilerPath = @("$env:LOCALAPPDATA/Programs/Inno Setup 6/ISCC.exe", 'C:/Program Files (x86)/Inno Setup 6/ISCC.exe', 'C:/Program Files/Inno Setup 6/ISCC.exe') | Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    if (!$compilerPath) { throw 'Install Inno Setup 6 to package the installer.' }
    & $compilerPath "/DPayloadDir=$bundlePath" "/DResultDir=$outputPath" /DSkipSignTool "$rootPath/support/scripts/compile_windows_exe-inno.iss"
    if ($LASTEXITCODE -ne 0) { throw 'Installer packaging failed.' }
}
# Create a fresh archive staging directory so an existing review install's
# settings are neither reset nor included in a downloadable ZIP.
$portablePath = Join-Path $rootPath ('.local/windows-package-' + $Architecture + '-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $portablePath | Out-Null
Copy-Item "$bundlePath/*" $portablePath -Recurse -Force
foreach ($fileName in @('neardock_msix_helper.msix','install_msix_helper.ps1','neardock.exe.manifest','logo.ico')) {
    $filePath = Join-Path $portablePath $fileName
    if (Test-Path $filePath) { Remove-Item -LiteralPath $filePath }
}
Set-Content -LiteralPath "$portablePath/settings.json" -Value '{}' -Encoding utf8NoBOM
Copy-Item -Path @("$rootPath/LICENSE", "$rootPath/NOTICE.md", "$rootPath/THIRD_PARTY_NOTICES.md", "$rootPath/BRAND_ASSETS.md") -Destination $portablePath
Compress-Archive -Path "$portablePath/*" -DestinationPath "$outputPath/Neardock-1.0.0-windows-$Architecture.zip" -Force
$reviewPath = Join-Path $outputPath "portable-$Architecture"
New-Item -ItemType Directory -Force -Path $reviewPath | Out-Null
Get-ChildItem -LiteralPath $portablePath | Where-Object { $_.Name -ne 'settings.json' } | Copy-Item -Destination $reviewPath -Recurse -Force
if (!(Test-Path -LiteralPath "$reviewPath/settings.json")) { Copy-Item -LiteralPath "$portablePath/settings.json" -Destination "$reviewPath/settings.json" }
