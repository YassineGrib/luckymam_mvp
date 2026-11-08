param(
    [ValidateSet('debug', 'release')]
    [string]$Mode = 'debug',
    [ValidateSet('apk', 'appbundle')]
    [string]$Artifact = 'apk'
)

$ErrorActionPreference = 'Stop'
$taskWorkspace = Split-Path -Parent $PSScriptRoot
$flutterCommand = Get-Command flutter -ErrorAction Stop
$flutterRoot = Split-Path -Parent (Split-Path -Parent $flutterCommand.Source)
$dartExecutable = Join-Path $flutterRoot 'bin/cache/dart-sdk/bin/dart.exe'
$flutterSnapshot = Join-Path $flutterRoot 'bin/cache/flutter_tools.snapshot'
$socketDirectory = Join-Path $taskWorkspace 'scratch/jvm-sockets'
$temporaryDirectory = Join-Path $taskWorkspace 'scratch/jvm-tmp'
$previousJavaOptions = $env:JAVA_TOOL_OPTIONS

New-Item -ItemType Directory -Force -Path $socketDirectory, $temporaryDirectory | Out-Null
Push-Location $taskWorkspace
try {
    # Keep Windows Java socket paths short; only this build process inherits it.
    $env:JAVA_TOOL_OPTIONS = $previousJavaOptions +
        ' -Djdk.net.unixdomain.tmpdir="' + $socketDirectory + '"' +
        ' -Djava.io.tmpdir="' + $temporaryDirectory + '"'
    & $dartExecutable $flutterSnapshot build $Artifact "--$Mode" --no-pub
    if ($LASTEXITCODE -ne 0) { throw "Android build failed ($LASTEXITCODE)." }
}
finally {
    $env:JAVA_TOOL_OPTIONS = $previousJavaOptions
    Pop-Location
}
