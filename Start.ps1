param([switch]$SkipBuild, [switch]$NoBrowser, [switch]$Restart, [ValidateRange(1, 65535)][int]$Port = 5247)
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
Set-Location -LiteralPath $projectRoot
$url = "http://localhost:$Port"
$toolDirectory = Join-Path $projectRoot '.tools'
$runtimeRoot = [System.IO.Path]::GetFullPath((Join-Path $toolDirectory 'runtime'))
$lastBuildFile = Join-Path $toolDirectory 'last-build.json'

# Mo lai launcher khong build de len assembly cua website dang chay.
$existingHealth = $null
try { $existingHealth = Invoke-RestMethod "$url/api/health" -TimeoutSec 2 } catch { }
if ($existingHealth -and $existingHealth.status -eq 'ok') {
    $existingPage = $null
    try { $existingPage = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 2 } catch { }
    if ($existingHealth.application -eq 'RentalManagement' -or ($existingPage -and $existingPage.Content -match '<title>(An C|DVP Home)')) {
        if ($existingHealth.database -ne 'PostgreSQL') {
            throw 'Website dang chay ban cu. Ban hien tai chi dung PostgreSQL. Nhan Ctrl+C trong cua so dang chay website, sau do chay lai Start.cmd.'
        }
        if (-not $Restart) {
            Write-Host "Website da dang chay tai $url ($($existingHealth.database))."
            Write-Host 'Neu vua sua code/UI: chay Restart.cmd de dung web, build lai va mo ban moi.'
            if (-not $NoBrowser) { Start-Process $url }
            return
        }
    }
}
$listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
if ($Restart -and ($listeners | Where-Object { $_.Port -eq $Port })) {
    if (-not (Test-Path -LiteralPath $lastBuildFile)) { throw 'Khong co thong tin ban build de xac minh server. Hay Ctrl+C o cua so web cu roi chay lai.' }
    $restartDll = [System.IO.Path]::GetFullPath((Get-Content -LiteralPath $lastBuildFile -Raw | ConvertFrom-Json).AppDll)
    if (-not $restartDll.StartsWith($runtimeRoot + '\', [StringComparison]::OrdinalIgnoreCase) -or
        [System.IO.Path]::GetFileName($restartDll) -ne 'Rental.Api.dll') { throw 'Duong dan server da luu khong hop le; khong dung tien trinh.' }
    $urlPattern = '--urls\s+"?' + [regex]::Escape($url) + '(?:"|\s|$)'
    $webProcesses = @(Get-CimInstance Win32_Process -Filter "Name='dotnet.exe'" | Where-Object {
        $_.CommandLine -and $_.CommandLine.IndexOf($restartDll, [StringComparison]::OrdinalIgnoreCase) -ge 0 -and $_.CommandLine -match $urlPattern
    })
    if ($webProcesses.Count -ne 1) { throw "Khong xac minh duoc dung server DVP Home tren cong $Port; khong dung tien trinh khac. Hay Ctrl+C o cua so web cu." }
    Write-Host "Dang dung DVP Home tren cong $Port de build lai..."
    Stop-Process -Id $webProcesses[0].ProcessId -ErrorAction Stop
    Wait-Process -Id $webProcesses[0].ProcessId -Timeout 10 -ErrorAction SilentlyContinue
    # Tien trinh da thoat nhung Windows co the chua nha socket ngay.
    for ($releaseAttempt = 0; $releaseAttempt -lt 50; $releaseAttempt++) {
        $listeners = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().GetActiveTcpListeners()
        if (-not ($listeners | Where-Object { $_.Port -eq $Port })) { break }
        Start-Sleep -Milliseconds 100
    }
}
if ($listeners | Where-Object { $_.Port -eq $Port }) {
    throw "Cong $Port dang duoc su dung. Cho website khoi dong xong roi thu lai, hoac chay Start.ps1 -Port 5248."
}
New-Item -ItemType Directory -Path $toolDirectory -Force | Out-Null
$appDllPath = Join-Path $projectRoot 'Rental.Api\bin\Debug\net8.0\Rental.Api.dll'
$env:DOTNET_CLI_HOME = Join-Path $toolDirectory 'cli-home'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_SKIP_FIRST_TIME_EXPERIENCE = '1'
$env:DOTNET_GENERATE_ASPNET_CERTIFICATE = 'false'
$localSdk = Join-Path $toolDirectory 'dotnet\dotnet.exe'
$dotnetCommand = Get-Command dotnet -ErrorAction SilentlyContinue
if (Test-Path -LiteralPath $localSdk) { $dotnetExe = $localSdk }
elseif ($dotnetCommand -and ((& $dotnetCommand.Source --list-sdks) -match '^8\.')) { $dotnetExe = $dotnetCommand.Source }
else {
    Write-Host 'Dang tai .NET 8 SDK chinh thuc vao .tools (chi lan dau)...'
    $release = Invoke-RestMethod 'https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/8.0/releases.json'
    $architecture = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'win-arm64' } else { 'win-x64' }
    $sdkAsset = $release.releases[0].sdk.files | Where-Object { $_.rid -eq $architecture -and $_.name -like '*.zip' } | Select-Object -First 1
    $sdkArchive = Join-Path $toolDirectory 'dotnet-sdk.zip'
    Invoke-WebRequest $sdkAsset.url -OutFile $sdkArchive -UseBasicParsing
    if ((Get-FileHash -LiteralPath $sdkArchive -Algorithm SHA512).Hash -ne $sdkAsset.hash) { throw 'SDK checksum mismatch.' }
    Expand-Archive -LiteralPath $sdkArchive -DestinationPath (Join-Path $toolDirectory 'dotnet') -Force
    $dotnetExe = $localSdk
}

if (-not $SkipBuild) {
    $nodeCommand = Get-Command node -ErrorAction SilentlyContinue
    $bundledNode = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'
    if ($nodeCommand) { $nodeExe = $nodeCommand.Source }
    elseif (Test-Path -LiteralPath $bundledNode) { $nodeExe = $bundledNode }
    else {
        Write-Host 'Dang tai Node.js 22 LTS chinh thuc vao .tools...'
        $nodeIndex = Invoke-RestMethod 'https://nodejs.org/dist/index.json'
        $nodeVersion = ($nodeIndex | Where-Object { $_.version -like 'v22.*' -and $_.lts } | Select-Object -First 1).version
        $nodeArch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { 'arm64' } else { 'x64' }
        $nodeFile = "node-$nodeVersion-win-$nodeArch.zip"
        $nodeArchive = Join-Path $toolDirectory $nodeFile
        Invoke-WebRequest "https://nodejs.org/dist/$nodeVersion/$nodeFile" -OutFile $nodeArchive -UseBasicParsing
        $checksums = (Invoke-WebRequest "https://nodejs.org/dist/$nodeVersion/SHASUMS256.txt" -UseBasicParsing).Content
        $expected = (($checksums -split "`n" | Where-Object { $_.Trim().EndsWith($nodeFile) }) -split '\s+')[0]
        if ((Get-FileHash -LiteralPath $nodeArchive -Algorithm SHA256).Hash -ne $expected) { throw 'Node checksum mismatch.' }
        Expand-Archive -LiteralPath $nodeArchive -DestinationPath $toolDirectory -Force
        $nodeExe = Join-Path $toolDirectory "node-$nodeVersion-win-$nodeArch\node.exe"
    }
    $env:PATH = (Split-Path -Parent $nodeExe) + ';' + $env:PATH
    Push-Location -LiteralPath (Join-Path $projectRoot 'Frontend')
    try {
        if (-not (Test-Path -LiteralPath 'node_modules\vite\bin\vite.js')) {
            $pnpmCommand = Get-Command pnpm -ErrorAction SilentlyContinue
            $bundledPnpm = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\bin\fallback\pnpm.cmd'
            $npmCli = Join-Path (Split-Path -Parent $nodeExe) 'node_modules\npm\bin\npm-cli.js'
            if ($pnpmCommand) { & $pnpmCommand.Source install --frozen-lockfile --ignore-scripts }
            elseif (Test-Path -LiteralPath $bundledPnpm) { & $bundledPnpm install --frozen-lockfile --ignore-scripts }
            elseif (Test-Path -LiteralPath $npmCli) { & $nodeExe $npmCli install --no-audit --no-fund }
            else { throw 'Can cai Node.js LTS kem npm, hoac pnpm de tai dependency giao dien.' }
            if ($LASTEXITCODE -ne 0) { throw 'Tai dependency giao dien that bai.' }
        }
        & $nodeExe node_modules\typescript\bin\tsc --noEmit
        if ($LASTEXITCODE -ne 0) { throw 'TypeScript build failed.' }
        & $nodeExe node_modules\vite\bin\vite.js build
        if ($LASTEXITCODE -ne 0) { throw 'Frontend build failed.' }
    } finally { Pop-Location }
    & $dotnetExe restore Rental.Api\Rental.Api.csproj --packages (Join-Path $toolDirectory 'packages')
    if ($LASTEXITCODE -ne 0) { throw 'dotnet restore failed.' }
    # Moi ban build co thu muc rieng; server cu khong khoa file dich cua ban moi.
    $buildDirectory = Join-Path $runtimeRoot ((Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N'))
    & $dotnetExe build Rental.Api\Rental.Api.csproj --no-restore --output $buildDirectory
    if ($LASTEXITCODE -ne 0) { throw 'API build failed.' }
    $appDllPath = Join-Path $buildDirectory 'Rental.Api.dll'
    @{ AppDll = $appDllPath } | ConvertTo-Json | Set-Content -LiteralPath $lastBuildFile -Encoding UTF8
}
elseif (Test-Path -LiteralPath $lastBuildFile) {
    $lastBuild = Get-Content -LiteralPath $lastBuildFile -Raw | ConvertFrom-Json
    $cachedDllPath = [System.IO.Path]::GetFullPath($lastBuild.AppDll)
    if (-not $cachedDllPath.StartsWith($runtimeRoot + '\', [StringComparison]::OrdinalIgnoreCase) -or
        [System.IO.Path]::GetFileName($cachedDllPath) -ne 'Rental.Api.dll') {
        throw 'Duong dan ban build da luu khong hop le. Chay lai khong co -SkipBuild.'
    }
    $appDllPath = $cachedDllPath
}
if (-not (Test-Path -LiteralPath $appDllPath)) { throw 'Chua co API da build. Chay lai khong co -SkipBuild.' }
if (-not (Test-Path -LiteralPath 'Rental.Api\wwwroot\index.html')) { throw 'Chua build giao dien. Chay lai khong co -SkipBuild.' }
$env:ASPNETCORE_ENVIRONMENT = 'Development'
Write-Host "`nDVP HOME - $url"
Write-Host 'Demo: admin / Demo@123456 | manager / Demo@123456'
Write-Host 'Du lieu duoc giu lai. Ctrl+C de dung. Xem /api/health de kiem tra database dang dung.'
if (-not $NoBrowser) {
    # Mo trinh duyet sau khi API san sang, tranh tab trang/connection refused luc khoi dong.
    $browserScript = @"
for (`$attempt = 0; `$attempt -lt 60; `$attempt++) {
    try {
        `$health = Invoke-RestMethod '$url/api/health' -TimeoutSec 1
        if (`$health.application -eq 'RentalManagement' -and `$health.status -eq 'ok') {
            Start-Process '$url'
            exit
        }
    } catch { }
    Start-Sleep -Milliseconds 500
}
"@
    $encodedBrowserScript = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($browserScript))
    Start-Process powershell.exe -WindowStyle Hidden -ArgumentList @('-NoProfile', '-EncodedCommand', $encodedBrowserScript)
}
Push-Location -LiteralPath (Join-Path $projectRoot 'Rental.Api')
try {
    & $dotnetExe $appDllPath --urls $url
    if ($LASTEXITCODE -ne 0) { throw 'Website khoi dong that bai. Xem thong bao loi phia tren.' }
}
finally { Pop-Location }
